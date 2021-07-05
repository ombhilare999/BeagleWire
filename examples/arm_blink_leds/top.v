/////////////////////////////////////////////////////////////
//   Function of IP: Top module for wishbone leds
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

`default_nettype none

// Uncomment this for iverilog simulation
// (iverilog top.v -DNO_ICE40_DEFAULT_ASSIGNMENTS)

//`define SIM

`ifdef SIM
    `include "leds_wb.v"
    `include "../../components/gpmc_to_wishbone.v"
    `include "../../components/cells_sim.v"
`endif

module top 
(   
    // Clock 
    input  wire        clk,

    // led Output
    output wire [3:0]  led,

    //GPMC Input
    inout  wire [15:0]  gpmc_ad, //Data Multiplexed with Address
    input  wire       gpmc_advn, //ADVN(L : ADDR)
    input  wire       gpmc_csn1, //Chip Select(Low - On)
    input  wire       gpmc_wein, //Low = write operation
    input  wire        gpmc_oen, //Low = Read Operation
    input  wire        gpmc_clk  //GPMC clock
);

// Parameters for Address and Data
parameter ADDR_WIDTH = 1;
parameter DATA_WIDTH = 16;

// Wishbone Interfacing Nets:
wire [ADDR_WIDTH-1:0]     wbm_address;  //Wishbone Address Bus
wire [DATA_WIDTH-1:0]    wbm_readdata;  //Wishbone Data Bus for Read Access
wire [DATA_WIDTH-1:0]   wbm_writedata;  //Wishbone Bus for Write Access

wire     wbm_cycle;      //Wishbone Bus Cycle in Progress 
wire     wbm_strobe;     //Wishbone Data Strobe
wire     wbm_write;      //Wishbone Write Access 
wire     wbm_ack;        //Wishbone Acknowledge Signal 

wire     reset;          //Reset Signal
assign reset = 1'b1;     //Active Low Signal

gpmc_to_wishbone # (
    .ADDR_WIDTH(ADDR_WIDTH),      // Macro for Address  
    .DATA_WIDTH(DATA_WIDTH)       // Macro for Data
) wb_controller (
    //System Clock and Reset
    .clk(clk),                    //FPGA Clock
    .reset(reset),              //Master Reset for Wishbone Bus
    
    // GPMC INTERFACE 
    .gpmc_ad(gpmc_ad),            //Data Multiplexed with Address
    .gpmc_clk(gpmc_clk),          //GPMC clock
    .gpmc_advn(gpmc_advn),        //ADVN(L : ADDR)
    .gpmc_csn1(gpmc_csn1),        //Chip Select(Low - On)
    .gpmc_wein(gpmc_wein),        //Low = write operation
    .gpmc_oen(gpmc_oen),          //Low = Read Operation
    
    //Wishbone Interface Signals
    .wbm_address(wbm_address),     //Wishbone Address Bus for Read/Write Data
    .wbm_readdata(wbm_readdata),   //Wishbone ReadData (The data needs to send to BBB)
    .wbm_writedata(wbm_writedata), //Wishbone Bus for Write Access (The data from blocks)
    .wbm_write(wbm_write),       //Wishbone Write(High = Write)
    .wbm_strobe(wbm_strobe),     //Wishbone Data Strobe(Valid Data Transfer)
    .wbm_cycle(wbm_cycle),       //Wishbone Bus Cycle in Progress 
    .wbm_ack(wbm_ack)            //Wishbone Acknowledge Signal from Slave
);

leds_wb #(
    .ADDR_WIDTH(ADDR_WIDTH),      // Macro for Address  
    .DATA_WIDTH(DATA_WIDTH)       // Macro for Data
) leds_wb_controller (
    //System Clock and Reset
    .clk(clk),                  //FPGA Clock
    .reset(reset),              //Master Reset for Wishbone Bus

	// Leds
	.led(led),      //LEDs on BeagleWire

	// Wishbone interface
	.wbs_address(wbm_address),     //Wishbone Address Bus 
	.wbs_writedata(wbm_writedata), //Wishbone read data
	.wbs_readdata(wbm_readdata),   //Wishbone write data
	.wbs_write(wbm_write),  //Wishbone Write(High = Write)
	.wbs_cycle(wbm_cycle),  //Wishbone Bus Cycle in Progress 
	.wbs_ack(wbm_ack)       //Wishbone Acknowledge Signal from Slave
);

endmodule
