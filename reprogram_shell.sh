BOARD=adm-8v3
VIVADO=vivado_lab
STATIC_BITSTREAM=static_v1.bit
CLEAR_BITSTREAM=v1_clear.bit
ILA_STATIC=ila_v1.ltx
CONTAINER_NAME=a2-naiflo
FPGA_NUM=1

source /opt/Xilinx/Vivado_Lab/2017.2/settings64.sh
source get_static.sh
source sourceme$FPGA_NUM.sh

echo 1 > /sys/bus/pci/devices/$CONTAINER_PCI/remove

echo $JTAG
$VIVADO -mode batch -source ./prog_util/open_target.tcl -tclargs $STATIC_BITSTREAM 


echo 1 > /sys/bus/pci/rescan
echo $CONTAINER_PCI > /sys/bus/pci/drivers/xdma/unbind
echo $CONTAINER_PCI > /sys/bus/pci/drivers/xdma/bind

#SCP TO CONTAINER!!
#scp v1_clear.bit $CONTAINER_ADDRESS:/opt/program/clear.bit
lxc file push $CLEAR_BITSTREAM $CONTAINER_NAME/opt/program/clear.bit
