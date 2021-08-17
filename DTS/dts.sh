#!/bin/bash

#########################################################
## Script to compile dts file and copied to lib firmware
## usage: ./dts.sh <dts-file-name> 
## ex:  ./dts.sh BW-ICE40Cape-flash-00A0
#########################################################


dtc -O dtb -o $1.dtbo -b 0 -@ $1.dts && echo "dtbo file created"
sudo mv $1.dtbo /lib/firmware && echo "dtbo file copied to the /lib/firmware directory"