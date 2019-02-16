#!/usr/bin/env bash

################################################################################
# This script generates the file containing the serial numbers of all FPGAs.
################################################################################

source fpga.conf

rm -rf $FPGA_SERIAL
# lsusb -v -d 0x0403: | grep  -e iSerial | while read -r line; do
# 	jtag=${line##* };
# 	echo "$jtag" >> $FPGA_SERIAL
# done
lsusb -v -d 0x0403: | awk -F' +' '/iSerial/{print $4}' > $FPGA_SERIAL
cp $FPGA_SERIAL $FPGA_SERIAL.conf
sed -e 's/$/,NULL,NULL,NULL,NULL,NULL/g' -i $FPGA_SERIAL.conf
