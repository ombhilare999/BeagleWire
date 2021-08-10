# BeagleWire Programming 

- First of all add following lines in `.bashrc` at th end, so that those scripts can be run from anywhere.
- `vim /home/debian/.bashrc`

```
# To run beaglewire script from anywhere
 export PATH=$PATH:/home/debian/beaglewire/load_fw
```

- There are several ways for programming bitstream into BeagleWire:


## 1) Flashing the sram on beaglewire with bitstream:

```
    sudo su
    source /home/debian/.bashrc 
    bw-spi.sh <bin file to program>
    #Example: bw-spi.sh blink.bin
``` 


## 2) LKM module with the ice40-spi kernel driver:

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


