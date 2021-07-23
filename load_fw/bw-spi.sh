#!/bin/bash

##########################################
## Script to prgoram beaglewire with spi
##########################################

echo "Truncating file to max limit of 4194304"
truncate $1 -s 4194304 

echo "Changing Direction of BB Reset to Output"
echo 117 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio117/direction

echo "Activating the flash chip with 0xAB command"
./spi_test -d /dev/spidev1.0 -l 1 -m ab

echo "Flashing nor flash with the $1 bin file"
flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=25000000 -w $1 -c MX25L3273E

echo "Changing Direction of BB Reset to input"
echo in > /sys/class/gpio/gpio117/direction