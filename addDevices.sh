#!/bin/bash

#input validation
if [ "$#" != 4 ]; then
    echo "syntax: ./script CONTAINER INDEX MAJOR MINOR"
    exit 1
fi

#check if container exists
if lxc info $1 2>&1 | grep -q 'error'; then
    echo "Container $1 not found"
    exit 1
fi

if [ ! -c /dev/bus/usb/$3/$4 ]; then
    echo "/dev/bus/usb/$3/$4 does not exist"
    exit 1
fi

if [ ! -c /dev/xdma${2}_user ]; then
    echo "/dev/xdma${2}_user does not exist"
    exit 1
fi

if [ ! -c /dev/xdma${2}_h2c_0 ]; then
    echo "/dev/xdma${2}_h2c_0 does not exist"
    exit 1
fi

if [ ! -c /dev/xdma${2}_c2h_0 ]; then
    echo "/dev/xdma${2}_c2h_0 does not exist"
    exit 1
fi


lxc config device add $1 fpga$2 unix-char path=/dev/bus/usb/$3/$4 mode=666
lxc config device add $1 xdma${2}-user unix-char path=/dev/xdma${2}_user mode=666
lxc config device add $1 xdma${2}-c2h unix-char path=/dev/xdma${2}_c2h_0 mode=666
lxc config device add $1 xdma${2}-h2c unix-char path=/dev/xdma${2}_h2c_0 mode=666

echo "All devices added successfully"
exit 0