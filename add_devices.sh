#!/usr/bin/env bash

#input validation
if [ "$#" != 4 ]; then
    echo "syntax: ./script CONTAINER SERIAL INDEX ECE1373"
    exit 1
fi

#check if container exists
if lxc info $container 2>&1 | grep -q 'error'; then
    echo "Container $container not found"
    exit 1
fi

source fpga.conf

container=$1
serial=$2
index=$3
ece1373=$4

count=0
while read -r line; do
        count=$((count+1))
    if [[ "$line" == "$serial" ]]; then
        break
    fi
done < <(lsusb -v -d 0x0403: | awk -F' +' '/iSerial/{print $4}')
if [[ "$count" == 0 ]]; then
    echo "No FPGA matching the serial $serial found."
    exit 1
fi

major=$(lsusb -v -d 0x0403: | awk -F' +' '/^Bus/{print $2}' | grep -o '[0-9]\+' | sed -n ${count}p)
minor=$(lsusb -v -d 0x0403: | awk -F' +' '/^Bus/{print $4}' | grep -o '[0-9]\+' | sed -n ${count}p)

if [[ $(lxc config device list $container | grep fpga${index}) ]]; then
    lxc config device remove $container fpga${index}
fi
lxc config device add $container fpga${index} unix-char path=/dev/bus/usb/$major/$minor mode=666
lxc config set $container user.fpga-serial $serial
if [[ -e /dev/xdma${index}_user ]]; then
    if [[ $(lxc config device list $container | grep xdma${index}-user) ]]; then
        lxc config device remove $container xdma${index}-user
        lxc config device remove $container xdma${index}-c2h
        lxc config device remove $container xdma${index}-h2c
    fi
    lxc config device add $container xdma${index}-user unix-char path=/dev/xdma${index}_user mode=666
    lxc config device add $container xdma${index}-c2h unix-char path=/dev/xdma${index}_c2h_0 mode=666
    lxc config device add $container xdma${index}-h2c unix-char path=/dev/xdma${index}_h2c_0 mode=666
fi
if [[ -e /dev/rescan-fpga ]]; then
    if [[ $(lxc config device list $container | grep rescan-fpga) ]]; then
        lxc config device remove $container rescan-fpga
    fi
    lxc config device add $container rescan-fpga unix-char path=/dev/rescan-fpga mode=666
fi

if [[ -e sourceme${index}.sh ]]; then
    cp sourceme${index}.sh sourceme.sh
    if [[ $ece1373 == "TRUE" ]]; then
        lxc exec $container -- mkdir -p /opt/util/program
        lxc file push ./fpga_util/open_target.tcl $container/opt/util/program/
        lxc file push ./fpga_util/program.sh $container/opt/util/program/
        lxc file push ./fpga_util/reg_rw $container/opt/util/program/
        lxc file push ./bitstreams/clear.bit $container/opt/util/program/
        lxc file push ./sourceme.sh $container/opt/util/
        lxc exec $container -- chown -R root:$USER_GROUP /opt/util/
    else
        lxc file push ./sourceme.sh $container/opt/
    fi
    rm sourceme.sh
fi

exit 0
