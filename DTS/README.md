## DTS Overlays for BeagleWire Black

```
    .
    ├── BW-GPIO-ICE40Cape-00A0.dts    #Overlay for GPIO
    ├── BW-I2C-ICE40Cape-00A0.dts     #Overlay for I2C
    ├── BW-ICE40Cape-00A0.dts         #Overlay for LKM prog
    ├── BW-ICE40Cape-flash-00A0.dts   #Overlay for spi dev prog
    ├── BW-ICE40Cape-nospi-00A0.dts   #Overlay for spi tristate
    ├── BW-PWM-ICE40Cape-00A0.dts     #Overlay for PWM component
    ├── BW-SPI-ICE40Cape-00A0.dts     #Overlay for SPI component
    ├── dts.sh                        #Script for dts compilation
    └── README.md                     #Readme
```

- Script to compile dts file and copied to lib firmware: `dts.sh`

### Steps:
- Compiles the dts file and copies dtbo to the /lib/firmware directory
 
```
    chmod +x dts.sh
    ./dts.sh BW-ICE40Cape-flash-00A0
```