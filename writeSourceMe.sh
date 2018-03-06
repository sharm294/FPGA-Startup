#!/bin/bash
VIO_ADDR=0x90000
CONTAINER_ADDR=("localhost" "localhost")
BOARD=adm-8v3
VIVADO=vivado_lab
STATIC_BITSTREAM=static_v1.bit
CLEAR_BITSTREAM=v1_clear.bit
ILA_STATIC=ila_v1.ltx

source get_static.sh

rm -rf jtagCables
lsusb -v -d 0x0403: | grep  -e iSerial |while read -r line;do jtag=${line##* };   echo "$jtag" >> jtagCables; done;

i=0
filename="jtagCables"
while read -r line
do
    i=$((i+1))
    name=$line
    $VIVADO -mode batch -source prog_util/write_probe.tcl -tclargs localhost:3121/xilinx_tcf/Digilent/$name 0000000$i $ILA_STATIC 
done < "$filename"

i=0
filename="jtagCables"
while read -r line
do
    cmd="./tests/reg_rw /dev/xdma"$i"_user $VIO_ADDR"
    eval $cmd  
    output="$(eval $cmd | grep 'Read 32-bit')"
    vio_val=${output##* } 
    echo $vio_val
    vio_val=${vio_val:2:8}
    echo $vio_val
    cmd="echo 'ibase=16;obase=A;$vio_val' | bc"
    eval $cmd
    vio_val=$(eval $cmd)
    cmd="sed '${vio_val}q;d' jtagCables"
    jtag_cable=$(eval $cmd)
    echo $JTAG_CABLE
    echo "export JTAG=\"localhost:3121/xilinx_tcf/Digilent/$jtag_cable\"" > sourceme$i.sh
    echo "export XDMA=\"/dev/xdma$i\"" >> sourceme$i.sh
    cmd="find /sys/bus/pci/drivers/xdma/0000\:0*/xdma/xdma$i"
    cmd2="_user/dev"
    cmd=$cmd$cmd2
    output="$(eval $cmd)"
    IFS='/' read -r -a array <<< "$output"
    container_pci="${array[6]}"
    echo "export CONTAINER_PCI=\"$container_pci\"" >> sourceme$i.sh
    container_pci_addr="$(echo $container_pci | sed -r 's/:/\\:/g')"
    echo "export CONTAINER_PCI_ADDR=\"$container_pci_addr\"" >> sourceme$i.sh
    echo $container_pci_addr
    i=$((i+1))
    
done < "$filename"


