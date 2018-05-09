#!/bin/bash

###############################################################################
#This script gets the appropriate bitstreams and ILA files for the given board. 
###############################################################################

source fpga.conf

wget -q $WEBSITE/$BOARD/$STATIC_BITSTREAM_NAME \
	-O $BITSTREAM_DIR/$STATIC_BITSTREAM
wget -q $WEBSITE/$BOARD/$CLEAR_BITSTREAM_NAME \
	-O $BITSTREAM_DIR/$CLEAR_BITSTREAM
wget -q $WEBSITE/$BOARD/$STATIC_ILA_NAME \
	-O $BITSTREAM_DIR/$STATIC_ILA
