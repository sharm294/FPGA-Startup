#!/usr/bin/env bash

################################################################################
# This script copies over the udev python scripts to the udev folder. Note: 
# after copying the .rules file, it must be edited manually to reflect the 
# serial numbers of the FPGAs in this machine.
################################################################################

if [[ ! -d /etc/udev/scripts ]]; then
	mkdir /etc/udev/scripts
fi
mv ./udev/*.py /etc/udev/scripts
mv ./udev/53-fpga-usb.rules /etc/udev/rules.d/
python /etc/udev/scripts/write_json.py
