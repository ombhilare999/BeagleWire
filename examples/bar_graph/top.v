/////////////////////////////////////////////////////////////
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
//   Function of IP: Top Module for multiple bar graph wishbone controller
/////////////////////////////////////////////////////////////

`default_nettype none

// Uncomment this for iverilog simulation
// (iverilog top.v -DNO_ICE40_DEFAULT_ASSIGNMENTS)

//`define SIM

`ifdef SIM
    `include "bar_graph_wb.v"
    `include "intercon.v"
    `include "../../components/gpmc_to_wishbone.v"
    `include "../../components/cells_sim.v"
`endif


module top 
(   
    // Clock 
    input  wire        clk,

    // Bar Graph Output on PMODs
    output wire [7:0] pmod3,
    output wire [7:0] pmod4,

    //GPMC Input
    inout  wire [15:0]  gpmc_ad, //Data Multiplexed with Address
    input  wire       gpmc_advn, //ADVN(L : ADDR)
    input  wire       gpmc_csn1, //Chip Select(Low - On)
    input  wire       gpmc_wein, //Low = write operation
    input  wire        gpmc_oen, //Low = Read Operation
    input  wire        gpmc_clk  //GPMC clock
);

// Parameters for Address and Data
parameter ADDR_WIDTH = 8;
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
    .DATA_WIDTH(DATA_WIDTH),      // Macro for Data
    .TARGET("ICE40")              // Target("ICE40")   fpga prmitive
                                  // Target("GENERAL") verilog implementaion
) wb_controller (
    //System Clock and Reset
    .clk(clk),                    //FPGA Clock
    .reset(reset),                //Master Reset for Wishbone Bus
    
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



/*
    Wishbone Memmap
        Slave 0:  0x0000
        Slave 1:  0x0040
*/

parameter wb_decoder_width = 8;
parameter wb_no_slaves = 2;
parameter wb_slave_0 = 8'h00;
parameter wb_slave_1 = 8'h40;

wire [DATA_WIDTH-1:0]  wbi_readdata_0;
wire [DATA_WIDTH-1:0]  wbi_readdata_1;

wire [DATA_WIDTH-1:0]  wbi_writedata;
wire [ADDR_WIDTH-1:0]  wbi_address;

wire wbi_write;
wire [wb_no_slaves-1:0] wbi_strobe;
wire [wb_no_slaves-1:0] wbi_cycle;
wire [wb_no_slaves-1:0] wbi_ack; 

wb_intercon #(
    // Wishbone Slave Number and address info
    .wb_decoder_width(wb_decoder_width),     // Decoder Width
    .wb_no_slaves(wb_no_slaves),         // Number of Slaves
    .wb_slave_0(wb_slave_0),
    .wb_slave_1(wb_slave_1),
    .ADDR_WIDTH(ADDR_WIDTH),           // Parameters for Address and Data
	.DATA_WIDTH(DATA_WIDTH)
) wb_intercon_DUT (
    //System Clock and Reset
    .clk(clk),                    //FPGA Clock
    .reset(reset),                //Master Reset for Wishbone Bus

	// Wishbone Master in
    //Wishbone Interface Signals
    .wbm_address(wbm_address),     //Wishbone Address Bus for Read/Write Data
    .wbm_readdata(wbm_readdata),   //Wishbone ReadData (The data needs to send to BBB)
    .wbm_writedata(wbm_writedata), //Wishbone Bus for Write Access (The data from blocks)
    .wbm_write(wbm_write),       //Wishbone Write(High = Write)
    .wbm_strobe(wbm_strobe),     //Wishbone Data Strobe(Valid Data Transfer)
    .wbm_cycle(wbm_cycle),       //Wishbone Bus Cycle in Progress 
    .wbm_ack(wbm_ack),            //Wishbone Acknowledge Signal from Slave

    //Wishbone Intercon out
    .wbi_readdata_0(wbi_readdata_0),
    .wbi_readdata_1(wbi_readdata_1),
    .wbi_writedata(wbi_writedata),
    .wbi_address(wbi_address),
    .wbi_write(wbi_write),
    .wbi_strobe(wbi_strobe),
    .wbi_cycle(wbi_cycle) ,
    .wbi_ack(wbi_ack) 
);


bar_graph_wb #(
    .ADDR_WIDTH(ADDR_WIDTH),      // Macro for Address  
    .DATA_WIDTH(DATA_WIDTH)       // Macro for Data
) bar_graph_controller_0 (
    //System Clock and Reset
    .clk(clk),                  //FPGA Clock
    .reset(reset),              //Master Reset for Wishbone Bus

	// Leds
	.bar_graph(pmod3),      //LEDs on BeagleWire

	// Wishbone interface
	.wbs_address(wbi_address),     //Wishbone Address Bus 
	.wbs_writedata(wbi_writedata), //Wishbone read data
    .wbs_write(wbi_write),  //Wishbone Write(High = Write)
	.wbs_readdata(wbi_readdata_0),   //Wishbone write data
	.wbs_cycle(wbi_cycle[0]),   //Wishbone Bus Cycle in Progress 
    .wbs_strobe(wbi_strobe[0]), //Wishbone Strobe
	.wbs_ack(wbi_ack[0])        //Wishbone Acknowledge Signal from Slave
);


bar_graph_wb #(
    .ADDR_WIDTH(ADDR_WIDTH),      // Macro for Address  
    .DATA_WIDTH(DATA_WIDTH)       // Macro for Data
) bar_graph_controller_1 (
    //System Clock and Reset
    .clk(clk),                  //FPGA Clock
    .reset(reset),              //Master Reset for Wishbone Bus

	// Leds
	.bar_graph(pmod4),      //LEDs on BeagleWire

	// Wishbone interface
	.wbs_address(wbi_address),     //Wishbone Address Bus 
	.wbs_writedata(wbi_writedata), //Wishbone read data
    .wbs_write(wbi_write),  //Wishbone Write(High = Write)
	.wbs_readdata(wbi_readdata_1),   //Wishbone write data
	.wbs_cycle(wbi_cycle[1]),   //Wishbone Bus Cycle in Progress 
    .wbs_strobe(wbi_strobe[1]), //Wishbone Strobe
	.wbs_ack(wbi_ack[1])        //Wishbone Acknowledge Signal from Slave
);


endmodule