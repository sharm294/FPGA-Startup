#!/usr/bin/env bash

#input validation
if [ "$#" != 3 ]; then
    echo "syntax: ./script CONTAINER SERIAL INDEX"
    exit 1
fi

#check if container exists
if lxc info "$container" 2>&1 | grep -q 'error'; then
    echo "Container $container not found"
    exit 1
fi

source fpga.conf

container=$container
serial=$2
index=$3

count=-1
lsusb -v -d 0x0403: | awk -F' +' '/iSerial/{print $4}' | while read -r line; do
	count=$((count+1))
    if [[ "$line" == "$serial" ]]; then
        break
    fi
done

if [[ "$count" == -1 ]]; then
    echo "No FPGA matching the serial $serial found."
    exit 1
fi

major=$(lsusb -v -d 0x0403: | awk -F' +' '/^Bus/{print $2}' | grep -o '[0-9]\+' | sed -n ${count}p)
minor=$(lsusb -v -d 0x0403: | awk -F' +' '/^Bus/{print $4}' | grep -o '[0-9]\+' | sed -n ${count}p)

lxc config device add "$container" fpga"${index}" unix-char path=/dev/bus/usb/"$major"/"$minor" mode=666
lxc config set "$container" user.fpga-serial "$serial"
if [[ -e /dev/xdma${index}_user ]]; then
    lxc config device add "$container" xdma"${index}"-user unix-char path=/dev/xdma"${index}"_user mode=666
    lxc config device add "$container" xdma"${index}"-c2h unix-char path=/dev/xdma"${index}"_c2h_0 mode=666
    lxc config device add "$container" xdma"${index}"-h2c unix-char path=/dev/xdma"${index}"_h2c_0 mode=666
fi

if [[ -e sourceme${index}.sh ]]; then
    cp sourceme"${index}".sh sourceme.sh
    lxc file push ./sourceme.sh "$container"/opt/util/
    lxc exec "$container" -- chown root:"$USER_GROUP" /opt/util/sourceme.sh
    rm sourceme.sh
fi

echo "All devices added successfully"
exit 0
