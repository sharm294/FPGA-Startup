BOARD=adm-8v3
STATIC_BITSTREAM=static_v1.bit
CLEAR_BITSTREAM=v1_clear.bit
ILA_STATIC=ila_v1.ltx
CONTAINER_ADDRESS=localhost
#CONTAINER_PCI_ADDRESS=0000\:01\:00.0
#CONTAINER_PCI=0000:01:00.0
#FPGA_NUM=0
CONTAINER_PCI_ADDRESS=0000\:02\:00.0
CONTAINER_PCI=0000:02:00.0
FPGA_NUM=1

source get_static.sh

echo 1 > /sys/bus/pci/devices/$CONTAINER_PCI_ADDRESS/remove
source /opt/Xilinx/Vivado/2017.2/settings64.sh

source sourceme$FPGA_NUM.sh
echo $JTAG
vivado -mode batch -source ./prog_util/open_target.tcl -tclargs $STATIC_BITSTREAM 


echo 1 > /sys/bus/pci/rescan
echo $CONTAINER_PCI > /sys/bus/pci/drivers/xdma/unbind
echo $CONTAINER_PCI > /sys/bus/pci/drivers/xdma/bind

#SCP TO CONTAINER!!
scp v1_clear.bit $CONTAINER_ADDRESS:/opt/program/clear.bit
