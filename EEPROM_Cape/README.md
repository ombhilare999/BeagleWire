## Writing EEPROM configuration contents

- BeagleWire cape has a EEPROM memory, so that the BBB device overlay is automatically loaded up on each boot up. 
- EEPROM contents and loading script are located in BeagleWire software repository.
- **So once we program the eeprom, then we don't have to explicitly add overlay info in uEnv.txt at any addr4**
- If `BW-ICE40Cape-00A0.dtbo` is present in /lib/firmware then it will be automatically loaded.

```
cd BeagleWire/EEPROM_Cape/
sudo ./load_eeprom.sh
```

Follow Complete guide here: [BeagleWire Starting Guide](https://beaglewire.github.io/Blogs/Getting_BBB_Ready_for_BeagleWire.html)