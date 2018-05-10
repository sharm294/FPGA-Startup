dev="rescan-fpga"
major="$(grep "$dev" /proc/devices | cut -d ' ' -f 1)"
sudo mknod "/dev/$dev" c "$major" 0
sudo chmod 666 /dev/$dev
