#!/usr/bin/env bash

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repoPath=${scriptPath%"FPGA-Startup"*}
repoPath=$repoPath"FPGA-Startup/"

file=grep --include="sourceme*.sh" -rlw $repoPath -e $1
if [[ ! -f $file ]]; then
	return -100
else
	source $file

	echo 1 > /sys/bus/pci/devices/$FPGA_PCI/remove
	echo 1 > /sys/bus/pci/rescan
	echo $FPGA_PCI > /sys/bus/pci/drivers/xdma/unbind
	echo $FPGA_PCI > /sys/bus/pci/drivers/xdma/bind

	return 0
fi
