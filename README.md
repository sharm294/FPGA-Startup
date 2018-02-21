# FPGAHypervisorStartupScripts

First make all the dependent binaries

- ``cd drivers``
- ``make``
- ``cd ../test``
- ``make``

Then program the FPGAs for the first time:
- ``source programShells_first.sh``

Reboot FPGAs for the first time to enumerate:
- ``sudo reboot``

Load drivers:
- ``insmod driver/xdma.ko``

Then make the sourcemes':
: ``source writeSourceme.sh``

Deploy the container with the usb (lsusb) and xdma<num> (according to sourceme<num>.sh) to appropriate container. This needs to be scripted better... Maybe make a script to deploy :)

In the container also make an /opt/program/ directory and move the clear bitstream there (with the name clear.bit)
- ``ssh <CONTAINER ADDRESS> 'mkdir -p /opt/program'``
- ``scp v1_clear.bit <CONTAINER ADDRESS>:/opt/program``
