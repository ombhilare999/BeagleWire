
/////////////////////////////////////////////////////////////
//   Function of IP: Top module for SDRAM-Litedram Controller
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

`default_nettype none

//`define SIM

`ifdef SIM
    `include "../../components/gpmc_to_wishbone.v"
    `include "../../components/sdram_litedram.v"
`endif


module top 
(
    // Clock and Reset
    input  wire        clk,
    input  wire      reset,

    //GPMC Input
    inout  wire [15:0]  gpmc_ad,  //Data Multiplexed with Address
    input  wire       gpmc_advn,  //ADVN(L : ADDR)
    input  wire       gpmc_csn1,  //Chip Select(Low - On)
    input  wire       gpmc_wein,  //Low = write operation
    input  wire        gpmc_oen,  //Low = Read Operation
    input  wire        gpmc_clk,  //GPMC clock

    //Debug
    output wire init_done,       //led 0
    output wire init_error,      //led 1
    output wire [7:0] pmod3,
    
    //SDRAM:
    output wire [12:0] sdram_a,
    inout  wire [7:0]  sdram_dq,
    output wire [1:0]  sdram_ba,

    output  wire sdram_cke,
    output  wire sdram_ras_n,
    output  wire sdram_cas_n,
    output  wire sdram_we_n,
    output  wire sdram_cs_n,
    output  wire sdram_dm,
);

// Parameters for Address and Data
parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 16;

// Wishbone Interfacing Nets:
wire [ADDR_WIDTH-1:0]     wbm_address;  //Wishbone Address Bus
wire [DATA_WIDTH-1:0]    wbm_readdata;  //Wishbone Data Bus for Read Access
wire [DATA_WIDTH-1:0]   wbm_writedata;  //Wishbone Bus for Write Access

wire     wbm_cycle;      //Wishbone Bus Cycle in Progress 
wire     wbm_strobe;     //Wishbone Data Strobe
wire     wbm_write;      //Wishbone Write Access 
wire     wbm_ack;        //Wishbone Acknowledge Signal 

wire          rst;          //Reset Signal
wire   user_reset;
assign rst = 1'b1;     //Active Low Signal

gpmc_to_wishbone # (
    .ADDR_WIDTH(ADDR_WIDTH),      // Macro for Address  
    .DATA_WIDTH(DATA_WIDTH),      // Macro for Data
    .TARGET("ICE40")              // Target("ICE40")   fpga prmitive
                                  // Target("GENERAL") verilog implementaion
) wb_controller (
    //System Clock and Reset
    .clk(clk),                    //FPGA Clock
    .reset(rst),                  //Master Reset for Wishbone Bus
    
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

wire [16:0] user_port_wishbone_adr;
wire [16:0] user_port_wishbone_dat_w;
wire [16:0] user_port_wishbone_dat_r;
wire [1:0] user_port_wishbone_sel;
wire user_port_wishbone_cyc;
wire user_port_wishbone_stb;
wire user_port_wishbone_ack;
wire user_port_wishbone_we;
wire user_port_wishbone_err;

litedram_core litedram_core_controller
(   
    //Clock and Reset
	.clk(clk),                   //FPGA Clock
	.rst(rst),                   //Master Reset for Wishbone Bus
	
    //SDRAM signals
    .sdram_a(sdram_a),
    .sdram_dq(sdram_dq),
	.sdram_ba(sdram_ba),
	.sdram_ras_n(sdram_ras_n),
	.sdram_cas_n(sdram_cas_n),
	.sdram_we_n(sdram_we_n),
	.sdram_cs_n(sdram_cs_n),
	.sdram_dm(sdram_dm),
	.sdram_cke(sdram_cke),

    //Debug Signals
	.init_done(init_done),
	.init_error(init_error),

    //Wishbone Control Port
	.wb_ctrl_adr(wbm_address),
	.wb_ctrl_dat_w(wbm_writedata),
	.wb_ctrl_dat_r(wbm_readdata),
    .wb_ctrl_cyc(wbm_cycle),
	.wb_ctrl_stb(wbm_strobe),
	.wb_ctrl_ack(wbm_ack),
	.wb_ctrl_we(wbm_write),
//	.wb_ctrl_sel(),
//	.wb_ctrl_cti(),
//	.wb_ctrl_bte(),
//	.wb_ctrl_err(),

    //User Clock and Reset
	.user_clk(clk),
	.user_rst(user_reset),
	
    //Wishbone User Port
    .user_port_wishbone_0_adr(user_port_wishbone_adr),
	.user_port_wishbone_0_dat_w(user_port_wishbone_dat_w),
	.user_port_wishbone_0_dat_r(user_port_wishbone_dat_r),
	.user_port_wishbone_0_cyc(user_port_wishbone_cyc),
	.user_port_wishbone_0_stb(user_port_wishbone_stb),
	.user_port_wishbone_0_ack(user_port_wishbone_ack),
	.user_port_wishbone_0_we(user_port_wishbone_we)
//	.user_port_wishbone_0_sel(user_port_wishbone_sel),
//	.user_port_wishbone_0_err(user_port_wishbone_err)
);

bar_graph_wb #(
    .ADDR_WIDTH(ADDR_WIDTH),      // Macro for Address  
    .DATA_WIDTH(DATA_WIDTH)       // Macro for Data
) bar_graph_controller_0 (
    //System Clock and Reset
    .clk(clk),                  //FPGA Clock
    .reset(rst),              //Master Reset for Wishbone Bus

	// Leds
	.bar_graph(pmod3),      //LEDs on BeagleWire

	// Wishbone interface
	.wbs_address(user_port_wishbone_adr),      //Wishbone Address Bus 
	.wbs_writedata(user_port_wishbone_dat_w),  //Wishbone read data
    .wbs_readdata(user_port_wishbone_dat_r),   //Wishbone write data
    .wbs_write(user_port_wishbone_we),    //Wishbone Write(High = Write)
	.wbs_cycle(user_port_wishbone_cyc),   //Wishbone Bus Cycle in Progress 
    .wbs_strobe(user_port_wishbone_stb),  //Wishbone Strobe
	.wbs_ack(user_port_wishbone_ack)      //Wishbone Acknowledge Signal from Slave
);

endmodule