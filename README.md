# FPGAHypervisorStartupScripts

First make all the dependent binaries
``cd drivers``
``make``
``cd ../test``
``make``

Then program the FPGAs for the first time
``source programShells_first.sh``

Reboot FPGAs for the first time to enumerate
``sudo reboot``

Load drivers
``insmod driver/xdma.ko``

Then make the sourcemes'
``source writeSourceme.sh``

Deploy the container with the usb (lsusb) and xdma<num> (according to sourceme<num>.sh) to appropriate container
