# FPGA-Startup

##Quick Initial Start
``make``  
``./write_serials.sh``  
``./get_static.sh``  
``./program_fpgas.sh``  
``sudo reboot``  
``make load``  
``./write_source.sh``  
``sudo ./udev.sh``  
Then edit ``/etc/udev/rules.d/53-fpga-usb.rules`` using the existing example as a template for all FPGAs on the machine.
