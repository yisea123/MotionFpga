![CI/VSG](https://github.com/Malcolmnixon/MotionFpga/workflows/CI/VSG/badge.svg) ![CI/VHDLTest](https://github.com/Malcolmnixon/MotionFpga/workflows/CI/VHDLTest/badge.svg) [![Documented](https://codedocs.xyz/Malcolmnixon/MotionFpga.svg)](https://codedocs.xyz/Malcolmnixon/MotionFpga/)

# Motion Fpga
This project builds a Motion FPGA used by processor to easily control motion devices. It is intended for use in projects such as:
* 3D Printers
* CnC Milling Machines
* General Robotics

# Target Hardware
This project has targets for the following FPGAs:
* Lattice MachXO2-7000HE [Breakout Board](https://www.latticesemi.com/products/developmentboardsandkits/machxo2breakoutboard)
* Lattice MachXO3D-9400HC [Breakout Board](https://www.latticesemi.com/products/developmentboardsandkits/machxo3d_breakout_board)

# Overview
Numerous motion-control devices require I/O signals which can be cumbersome for a processor to manage directly.
Instead this FPGA provides a simpler interface with the processor, and manage the I/O signals.

Common types of motion-control devices include:
* Digital Input (sensors, status, etc)
* Digital Output (enables, LEDs, etc)
* PWM Output (heaters, fans, etc)
* Stepper Drivers (motors)
* Quadrature Inputs (encoders)

The types of high-speed interfaces between a processor and the Motion FPGA include:
* SPI
* Virtual External Memory (Memory read/write)
* PCIe (Memory read/write)

# Doxygen Documentation
A light-weight version of the Doxygen output can be found on [CodeDocs.xyz](https://codedocs.xyz/Malcolmnixon/MotionFpga/).
