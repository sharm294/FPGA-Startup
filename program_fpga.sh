#!/bin/bash

################################################################################
# This script can be used to program a single FPGA with a bitstream.
################################################################################

#input validation
if [[ $# != 1 && $# != 5 ]]; then
	echo "Usage: script FPGA_SERIAL [staticBit] [clearBit] [PCI_en] [Clear_en]"
	exit -1
fi

source fpga.conf
source /opt/Xilinx/$VIVADO/$VIVADO_VERSION/settings64.sh

#check if the FPGA serial argument exists on this computer
serialFile=$(grep -Elir --include=$FPGA_SERIAL "$1")
if [[ ! -f $serialFile ]]; then
	echo "Serial device not found. Check for typos or run write_serials.sh"
	exit -1
fi

#update bitstreams with command line arguments if not "NULL"
if [[ $# == 5 ]]; then
	if [[ $2 != "NULL" ]]; then
		STATIC_BITSTREAM=$2
	fi
	if [[ $3 != "NULL" ]]; then
		CLEAR_BITSTREAM=$3
	fi
	if [[ $4 != "NULL" ]]; then
		PCI_ENABLE=$4
	fi
	if [[ $5 != "NULL" ]]; then
		CLEAR_ENABLE=$5
	fi
fi

#these if statements check the following:
# -if PCI is disabled, there is no need to remove or rescan PCI
# -if PCI is enabled, but there's no sourceme*.sh, then this is the first time 
#  the FPGA is being programmed. Again, no need to remove or rescan PCI
# -otherwise, we're reprogramming the FPGA, in which case, we do need to rescan
if [[ $PCI_ENABLE == "1" ]]; then
	sourceFile=$(grep -Elir --include=sourceme*.sh "$1")
	if [[ -e $sourceFile ]]; then	
		source $sourceFile
		echo 1 > /sys/bus/pci/devices/$FPGA_PCI/remove
	fi
fi

export JTAG="localhost:3121/xilinx_tcf/Digilent/$1"
$VIVADO -mode batch -source $FPGA_UTIL_DIR/open_target.tcl \
	-tclargs $BITSTREAM_DIR/$STATIC_BITSTREAM

if [[ $PCI_ENABLE == "1" ]]; then
	echo 1 > /sys/bus/pci/rescan
	if [[ -e $sourceFile ]]; then
		echo $FPGA_PCI > /sys/bus/pci/drivers/xdma/unbind
		echo $FPGA_PCI > /sys/bus/pci/drivers/xdma/bind
	fi
fi

if [[ $CLEAR_ENABLE == "1" ]]; then
	TMP_FILE=./container.tmp
	touch $TMP_FILE
	python list_containers.py $1 $TMP_FILE
	while read -r container; do
		lxc file push $CLEAR_BITSTREAM $container$CONTAINER_PATH/$CLEAR_BITSTREAM
	done < "$TMP_FILE"
	rm $TMP_FILE
fi
