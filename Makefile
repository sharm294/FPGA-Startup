include fpga.conf

all:
	$(MAKE) -C $(XDMA_DIR) -f Makefile
	$(MAKE) -C $(RESCAN_DIR) -f Makefile
	$(MAKE) -C $(FPGA_UTIL_DIR) -f Makefile

load:
	$(MAKE) -C $(XDMA_DIR) -f Makefile load
	$(MAKE) -C $(RESCAN_DIR) -f Makefile load

unload:
	$(MAKE) -C $(XDMA_DIR) -f Makefile unload
	$(MAKE) -C $(RESCAN_DIR) -f Makefile unload

clean:
	$(MAKE) -C $(XDMA_DIR) -f Makefile clean
	$(MAKE) -C $(RESCAN_DIR) -f Makefile clean
	$(MAKE) -C $(FPGA_UTIL_DIR) -f Makefile clean