# BeagleWire Programming 


- There are several ways for programming bitstream into BeagleWire:

## 1) LKM module with the ice40-spi kernel driver:

- For this you need to load following DTS file into `uEnv.txt`

```
    sudo vim /boot/uEnv.txt
    
    #Add this overlay line at addr4 place:

    uboot_overlay_addr4=/lib/firmware/BW-ICE40Cape-00A0.dtbo 

    #Reboot after this
``` 

- `cd beaglewire/load_fw`
- `make`
- `./bw-prog.sh blink.bin` 
- Using this way one can program any bitstream directly to the FPGA via ice40-spi kernel driver and LKM module.

## 2) Flashing the sram on beaglewire with bitstream:

- For this first you need to load following DTS file into `uEnv.txt`

```
    sudo vim /boot/uEnv.txt
    
    #Add this overlay line at addr4 place:

    uboot_overlay_addr4=/lib/firmware/BW-ICE40Cape-flash-00A0.dtbo 

    #Reboot after this
``` 
- `cd beaglewire/load_fw`
- `./bw-spi.sh blink.bin`
- Now we need to tristate the spi line so it doesn't interfere with spi bootup. For that we have one overlay:

```
    sudo vim /boot/uEnv.txt
    
    #Add this overlay line at addr4 place:

    uboot_overlay_addr4=/lib/firmware/BW-ICE40Cape-nospi-00A0.dtbo 

    #Reboot after this
```
- Reset the FPGA now the sram is flashed with bitstream. 




