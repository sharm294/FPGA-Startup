#!/usr/bin/env bash

################################################################################
# This script programs all FPGAs listed in $FPGA_SERIAL.conf with the bitstream
################################################################################

source fpga.conf

while IFS="," read -r serial staticBit clearBit ila pci clearEn; do
	sudo ./program_fpga.sh $serial $staticBit $clearBit $pci $clearEn
done < "$FPGA_SERIAL.conf"
