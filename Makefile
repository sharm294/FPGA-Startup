include fpga.conf

all: xdma rescan-fpga reg_rw

xdma:
	$(MAKE) -C $(XDMA_DIR) all

rescan-fpga:
	$(MAKE) -C $(RESCAN_DIR) all

reg_rw:
	$(MAKE) -C $(FPGA_UTIL_DIR) all

load:
	$(MAKE) -C $(XDMA_DIR) load
	$(MAKE) -C $(RESCAN_DIR) load

unload:
	$(MAKE) -C $(XDMA_DIR) unload
	$(MAKE) -C $(RESCAN_DIR) unload

clean:
	unload
	$(MAKE) -C $(XDMA_DIR) clean
	$(MAKE) -C $(RESCAN_DIR) clean
	$(MAKE) -C $(FPGA_UTIL_DIR) clean