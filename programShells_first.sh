#!/bin/bash
BOARD=adm-8v3
STATIC_BITSTREAM=static_v1.bit
CLEAR_BITSTREAM=v1_clear.bit
ILA_STATIC=ila_v1.ltx

source get_static.sh
rm -rf jtagCables
lsusb -v -d 0x0403: | grep  -e iSerial |while read -r line;do jtag=${line##* };   echo "$jtag" >> jtagCables; export JTAG=\"localhost:3121/xilinx_tcf/Digilent/$jtag; echo $JTAG; vivado -mode batch -source ./prog_util/open_target.tcl -tclargs static_v1.bit; done;

