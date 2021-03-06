-------------------------------------------------------------------------------
--! @file
--! @brief SPI Slave testbench module
-------------------------------------------------------------------------------

--! Using IEEE library
LIBRARY ieee;

--! Using IEEE standard logic components
USE ieee.std_logic_1164.ALL;

--! @brief SPI Slave testbench module
ENTITY spi_slave_tb IS
END ENTITY spi_slave_tb;

--! Architecture tb of spi_slave_tb entity
ARCHITECTURE tb OF spi_slave_tb IS

    --! Clock period
    CONSTANT c_clk_period : time := 100 ns;
    
    -- Signals to unit under test
    SIGNAL clk         : std_logic;                     --! Clock
    SIGNAL rst         : std_logic;                     --! Asynchronous reset
    SIGNAL spi_cs      : std_logic;                     --! SPI chip select input to uut
    SIGNAL spi_sclk    : std_logic;                     --! SPI clock input to uut
    SIGNAL spi_mosi    : std_logic;                     --! SPI MOSI input to uut
    SIGNAL spi_miso    : std_logic;                     --! SPI MISO output from uut
    SIGNAL dat_rd_reg  : std_logic_vector(31 DOWNTO 0); --! Data read register input to uut
    SIGNAL dat_wr_reg  : std_logic_vector(31 DOWNTO 0); --! Data write register output from uut
    SIGNAL dat_wr_done : std_logic;                     --! Data write done output from uut
    
    -- Test signals
    SIGNAL mosi_wr : std_logic_vector(31 DOWNTO 0); --! SPI MOSI test pattern to drive into uut
    SIGNAL miso_rd : std_logic_vector(31 DOWNTO 0); --! SPI MISO output pattern driven from uut

BEGIN

    --! Instantiate spi_slave as unit under test
    i_uut : ENTITY work.spi_slave(rtl)
        GENERIC MAP (
            size => 32
        )
        PORT MAP (
            clk_in          => clk,
            rst_in          => rst,
            spi_cs_in       => spi_cs,
            spi_sclk_in     => spi_sclk,
            spi_mosi_in     => spi_mosi,
            spi_miso_out    => spi_miso,
            dat_rd_reg_in   => dat_rd_reg,
            dat_wr_reg_out  => dat_wr_reg,
            dat_wr_done_out => dat_wr_done
        );
        
    --! @brief Clock generation process
    pr_clock : PROCESS IS
    BEGIN
    
        -- Low for 1/2 clock
        clk <= '0';
        WAIT FOR c_clk_period / 2;
        
        -- High for 1/2 clock
        clk <= '1';
        WAIT FOR c_clk_period / 2;
        
    END PROCESS pr_clock;
    
    --! @brief Stimulus process
    pr_stimulus : PROCESS IS
    BEGIN
    
        -- Set SPI bus idle
        spi_cs   <= '1'; -- CS: high-idle
        spi_sclk <= '0'; -- SCLK: low-idle
        spi_mosi <= '0'; -- MOSI: idle
        
        -- Reset for 5 clocks
        REPORT "Hold in Reset" SEVERITY note;
        rst <= '1';
        WAIT FOR c_clk_period * 5;
        ASSERT (spi_miso    = '0') REPORT "Expected spi_miso low while in reset" SEVERITY error;
        ASSERT (dat_wr_done = '0') REPORT "Expected dat_wr_done low while in reset" SEVERITY error;
        
        -- Release reset for 5 clocks
        REPORT "Take out of Reset" SEVERITY note;
        rst <= '0';
        WAIT FOR c_clk_period * 5;
        ASSERT (spi_miso    = '0') REPORT "Expected spi_miso low while idle" SEVERITY error;
        ASSERT (dat_wr_done = '0') REPORT "Expected dat_wr_done low while idle" SEVERITY error;
        
        -- Provide test pattern
        dat_rd_reg <= X"AA550011";
        mosi_wr    <= X"DEADBEEF";
        
        -- Start SPI transfer
        REPORT "Start SPI Transfer" SEVERITY note;
        spi_cs <= '0';
        WAIT FOR c_clk_period;
        
        -- Wait for 5 clocks (CS-to-Start)
        WAIT FOR c_clk_period * 5;
        
        -- Clock SPI bus
        REPORT "Transfer 32 Bits" SEVERITY note;
        FOR i IN 31 DOWNTO 0 LOOP
            -- Drive data and first edge
            spi_mosi <= mosi_wr(i);
            spi_sclk <= '1';
            WAIT FOR c_clk_period * 2;

            -- Capture data and drive second edge
            miso_rd(i) <= spi_miso;
            spi_sclk   <= '0';
            WAIT FOR c_clk_period * 2;
        END LOOP;

        -- Wait for 5 clocks (End-to-CS)
        WAIT FOR c_clk_period * 5;
        
        -- End SPI transfer
        REPORT "End SPI Transfer" SEVERITY note;
        spi_cs <= '1';
        WAIT FOR c_clk_period;
        ASSERT (dat_wr_done = '1') REPORT "Expected dat_wr_done high for transfer done" SEVERITY error;
    
        -- Wait for 10 clocks
        WAIT FOR c_clk_period * 10;
        ASSERT (dat_wr_done = '0') REPORT "Expected dat_wr_done low after transfer done" SEVERITY error;
        
        -- Verify test patterns
        REPORT "Test Transfer Data" SEVERITY note;
        ASSERT (dat_wr_reg = mosi_wr) REPORT "Expected dat_wr_reg matches mosi_wr" SEVERITY error;
        ASSERT (miso_rd = dat_rd_reg) REPORT "Expected miso_rd matches dat_rd_reg" SEVERITY error;
    
        -- Log end of test
        REPORT "Finished" SEVERITY note;
        
        -- Finish the simulation
        std.env.finish;
        
    END PROCESS pr_stimulus;

END ARCHITECTURE tb;
