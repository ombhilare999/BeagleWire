## BeagleWire Components:

### File Structure of Components:

```
.
├── cells_sim.v           # Included for Iverilog Simulation
├── dp-sync-ram.v
├── fifo.v
├── gpio-port.v
├── gpmc-sync.v
├── gpmc_to_wishbone.v    # gpmc to wishbone verilog IP
├── i2c-master.v
├── pwm.v
├── README.md
├── sdram_controller.v
├── spi-master.v
├── stepper_motor.v
├── tb_gpmc_to_wishbone.v # Testbench for gpmc to wishbone wrapper  
├── uart-rx.v
└── uart-tx.v
```

### Simulation:

- If needs to be run on the FPGA then `define SIM` should be commented 
- For Iverilog Simulation, Ensure `define SIM` is present in the wrapper

```
# Flag is used for FPGA primitives
iverilog tb_gpmc_to_wishbone.v -DNO_ICE40_DEFAULT_ASSIGNMENTS
./a.out
gtkwave a.vcd
```

### Write and Read Cycle simulation of gpmc to wishbone wrapper:

<p align="center">
  <img width="581" height="202" src="../images/gpmc_to_wishbone.png">
</p>


