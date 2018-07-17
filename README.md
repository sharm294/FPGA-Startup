# FPGA-Startup

## Description
This repository contains a set of scripts to make using FPGAs and using them with LXD containers easier. It supports getting bitstreams from an online repository, programming them onto all (or selected) FPGAs that are connected to the host with PCIe and USB. It supports designs with partial reconfiguration (e.g. providing a clear bitstream to the container if the FPGA is reprogrammed) and/or PCIe subsystems. For the latter case, a kernel module is provided that can be added to a container to enable an unprivileged user in the container to rescan the PCI bus and their particular FPGA using an authentication password. To support USB renumeration after a power cycle or reinsertion, udev scripts are provided that will scan and update the paths for any FPGAs a container may have.

## Dependencies

The following packages must be installed:
* python-pylxd (sudo apt-get install python-pylxd)
* bc (sudo apt install bc)

## Quick Initial Start
On a brand new machine:  
``make``  
``./write_serials.sh``  
``./get_static.sh``  
``./program_fpgas.sh``  
``sudo reboot``  
``make load``  
``./write_source.sh``  
``sudo ./udev.sh``  
Then edit ``/etc/udev/rules.d/53-fpga-usb.rules`` using the existing example as a template for all FPGAs on the machine. You need to change the serial numbers to match those on the machine.

## Files

### Configuration
There are two files that are intended to be modified by the user: ``fpga.conf`` and ``fpga_serials.conf``.
* ``fpga.conf``: this file is sourced by the majority of scripts and contains all the variables that the scripts use. Depending on your usage, some of these may need to change. Some of the parameters in this file can be overridden by command-line arguments or with ``fpga_serials.conf``. 
* ``fpga_serials.conf``: this file allows the user to selectively program FPGAs or otherwise program the FPGAs differently from each other. The syntax of the file by default is shown below:

  210308A129C2,NULL,NULL,NULL,NULL,NULL  
  210308A129AF,NULL,NULL,NULL,NULL,NULL

  where it lists all the FPGAs on the machine and the order represent the values of the serial, static bitstream, clear bitstream, ILA file, PCIe enable, and clear enable. If the value is left as NULL, then the values from ``fpga.conf`` are used. Otherwise, these values will be used instead. The static, clear and ILA files are assumed to be in the ``$BITSTREAM_DIR`` and must be the file names. The last two enables must be 1 (enabled) or 0 (disabled). The first states that the bitstream has a PCIe subsystem and the second enables whether a clear bitstream is needed.
  
  The ``program_fpgas.sh`` and ``write_source.sh`` use ``fpga_serial.conf`` to define which FPGAs are to be programmed. So before running these scripts, make sure this file is configured as needed.
  
## Todo
  
  * After reboot, drivers aren't loaded so any containers using drivers fail to start
  
