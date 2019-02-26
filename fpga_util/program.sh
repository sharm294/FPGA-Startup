#!/usr/bin/env bash

VIVADO_PATH=/opt/Xilinx/Vivado/2017.2/bin/vivado
CLEAR_BIT_PATH=/opt/util/program/clear.bit

if [ ! -f $VIVADO_PATH ]; then
  echo "Vivado not found"
  exit 1
fi

if [ ! -f $CLEAR_BIT_PATH ]; then
  echo "ERROR: Old Clear bitstream not found"
  exit 1
fi

if [ $# -ne 2 ]; then
  echo $0 requires two arguments: bitstream and clearing bitstream
  exit 1
fi

# Check first input for basic properties
if [ ! -f $1 ] || [[ $1 != *partial.bit ]]; then
  echo $1 not a bit file
  exit 1
fi

if [ ! -f $2 ] || [[ $2 != *partial_clear.bit ]]; then
  echo $2 not a bit file
  exit 1
fi

partial_prefix=${1%partial.bit}
clear_prefix=${2%partial_clear.bit}

if [[ $partial_prefix != $clear_prefix ]]; then
  echo "partial and clear bitstream names don't match"
fi

# Decouple PR region
user="_user"
app=$XDMA$user
/opt/util/program/reg_rw $app 0x80000 w 0x1 

# Program clearing bitstream
vivado -mode batch -source /opt/util/program/open_target.tcl -tclargs $CLEAR_BIT_PATH

# Program new partial bitstream
vivado -mode batch -source /opt/util/program/open_target.tcl -tclargs $1

# Move clear bitstream to replace old one
mv $CLEAR_BIT_PATH ${CLEAR_BIT_PATH}.old
cp $2 $CLEAR_BIT_PATH
chown :reg-users ${CLEAR_BIT_PATH}.old
chown :reg-users $CLEAR_BIT_PATH

# Couple PR region
/opt/util/program/reg_rw $app 0x80000 w 0x0

rm vivado*.log
rm vivado*.jou
