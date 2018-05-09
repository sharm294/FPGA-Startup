#!/bin/bash

################################################################################
# This script probes the FPGAs (that should have shells programmed already), 
# and matches their USB ports to their PCI addresses. Then, it writes source 
# scripts that each container can use to access the FPGAs easily.
################################################################################

source fpga.conf

if [[ ! -f $FPGA_SERIAL.conf ]]; then
	echo "$FPGA_SERIAL.conf doesn't exist. Run write_serials.sh to generate one"
	exit -1
fi

if [[ $# != 0 && $# != 1 ]]; then
	echo "Usage: script [ila]"
	exit -1
fi

#writes a unique value to each FPGA so it can be probed later to ID them
i=0
while IFS="," read -r serial staticBit clearBit ila pci clearEn; do
	if [[ $pci != "NULL" ]]; then
		PCI_ENABLE=$pci
	fi
	if [[ $PCI_ENABLE == "1" ]]; then
		i=$((i+1))
		name=$serial
		if [[ $ila != "NULL" ]]; then
			STATIC_ILA=$ila
		fi
		$VIVADO -mode batch -source $FPGA_UTIL_DIR/write_probe.tcl \
			-tclargs localhost:3121/xilinx_tcf/Digilent/$name 0000000$i \
				$BITSTREAM_DIR/$STATIC_ILA
	fi
done < "$FPGA_SERIAL.conf"

#reads FPGAs, and writes their data to sourceme*.sh files
i=0
while IFS="," read -r serial staticBit clearBit ila pci clearEn; do
	if [[ $pci != "NULL" ]]; then
		PCI_ENABLE=$pci
	fi
	if [[ $PCI_ENABLE == "1" ]]; then
		cmd="$TESTS_DIR/reg_rw /dev/xdma"$i"_user $VIO_ADDR"
		eval $cmd  
		output="$(eval $cmd | grep 'Read 32-bit')"
		vio_val=${output##* } 
		vio_val=${vio_val:2:8}
		cmd="echo 'ibase=16;obase=A;$vio_val' | bc"
		eval $cmd
		vio_val=$(eval $cmd)
		cmd="sed '${vio_val}q;d' $FPGA_SERIAL.conf | cut -d',' -f1"
		jtag_cable=$(eval $cmd)
		if [[ $DEBUG > "0" ]]; then
			echo $JTAG_CABLE
		fi
		echo "export JTAG=\"localhost:3121/xilinx_tcf/Digilent/$jtag_cable\"" \
			> sourceme$i.sh
		echo "export XDMA=\"/dev/xdma$i\"" >> sourceme$i.sh
		cmd="find /sys/bus/pci/drivers/xdma/0000\:0*/xdma/xdma$i"
		cmd2="_user/dev"
		cmd=$cmd$cmd2
		output="$(eval $cmd)"
		IFS='/' read -r -a array <<< "$output"
		fpga_pci="${array[6]}"
		echo "export FPGA_PCI=\"$fpga_pci\"" >> sourceme$i.sh
		fpga_pci_addr="$(echo $fpga_pci | sed -r 's/:/\\:/g')"
		echo "export FPGA_PCI_ADDR=\"$fpga_pci_addr\"" >> sourceme$i.sh
		password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
		echo "export FPGA_PASSWORD=\"$password\"" >> sourceme$i.sh
		if [[ $DEBUG > "0" ]]; then
			echo $fpga_pci_addr
		fi
		i=$((i+1))
	fi
done < "$FPGA_SERIAL.conf"
