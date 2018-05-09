SHELL := /bin/bash
TARGET_MODULE:=rescan-fpga

ifneq ($(KERNELRELEASE),)
	$(TARGET_MODULE)-objs := main.o device_file.o
	obj-m := $(TARGET_MODULE).o

# If we are running without kernel build system
else
	BUILDSYSTEM_DIR?=/lib/modules/$(shell uname -r)/build
	PWD:=$(shell pwd)

all : 
# run kernel build system to make module
	sed -i '/PATH_SUBSTITUTION/!b;n;cstatic const char string_path[] = "'$(shell pwd)'/kernel.sh";' device_file.c
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) modules

clean:
# run kernel build system to cleanup in current directory
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) clean

load:
	sudo insmod ./$(TARGET_MODULE).ko

unload:
	sudo rm -f /dev/$(TARGET_MODULE)
	sudo rmmod ./$(TARGET_MODULE).ko

endif

