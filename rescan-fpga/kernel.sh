#!/bin/bash

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repoPath=${scriptPath%"FPGA-Startup"*}
repoPath=$repoPath"FPGA-Startup/"

file=grep --include="sourceme*.sh" -rlw $repoPath -e $1
if [[ ! -f $file ]]; then
	return -100
source $file

echo 1 > /sys/bus/pci/devices/$CONTAINER_PCI/remove
echo 1 > /sys/bus/pci/rescan
echo $CONTAINER_PCI > /sys/bus/pci/drivers/xdma/unbind
echo $CONTAINER_PCI > /sys/bus/pci/drivers/xdma/bind

return 0
