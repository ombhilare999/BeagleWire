#!/bin/bash

##########################################
## Script to prgoram beaglewire with spi
##########################################

echo "|--------------------------------------------|"
echo "|-----Flashing Beaglewire with SPI MODE -----|"
echo "|--------------------------------------------|"

echo "Truncating file to max limit of 4194304"
truncate $1 -s 4194304 

echo "Changing Direction of BB Reset to Output so FPGA won't interfer in SPI FLASH Programming"
echo 117 > /sys/class/gpio/export || echo "GPIO export of resest pin failed, please rerun"
echo out > /sys/class/gpio/gpio117/direction || echo "GPIO out of reset pin failed, please rerun"

echo "Activating SPI mode"
config-pin P9_28 spi_cs
config-pin P9_31 spi_sclk

echo "Activating the flash chip with 0xAB command"
spi_test -d /dev/spidev1.0 -l 1 -m ab || echo "Failed, Rerun the script"

echo "Flashing nor flash with the $1 bin file"
flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=25000000 -w $1 -c MX25L3273E || echo "Failed, Rerun the script"

echo "Changing Direction of BB Reset to input"
echo in > /sys/class/gpio/gpio117/direction

echo "Deactivating SPI mode"
config-pin P9_28 gpio
config-pin P9_31 gpio

echo "|---------------------------------------------|"
echo "|----RESET THE FPGA to run the bitstream -----|"
echo "|---------------------------------------------|"