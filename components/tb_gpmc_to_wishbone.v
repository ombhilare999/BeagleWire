/////////////////////////////////////////////////////////////
//   Function of IP: Testbench for GPMC to Wishbone Conversion
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

`include "gpmc_to_wishbone.v"
`timescale 1s/1ps

module tb_gpmc_to_wishbone();

// Variables for the bridge
reg clk;
reg reset;

//GPMC interface
reg  [15:0 ]gpmc_ad_reg;
inout  [15:0]   gpmc_ad;        //Data Multiplexed with Address [16:1]
reg           gpmc_advn;      //Address Valid Enable(Address capture on ADVn rising edge)
reg           gpmc_csn1;      //Chip Select
reg           gpmc_wein;      //Write Enable (write access only)
reg           gpmc_oen;       //Output Enable (read access only)
reg           gpmc_clk;       //GPMC clock

//Wishbone Interface Signals
wire [15:0]    wbm_address;    //Wishbone Address Bus
reg [15:0]    wbm_readdata;   //Wishbone Data Bus for Read Access
wire [15:0]   wbm_writedata;  //Wishbone Bus for Write Access
reg           wbm_ack;        //Wishbone Acknowledge Signal
wire           wbm_cycle;      //Wishbone Bus Cycle in Progress 
wire          wbm_strobe;     //Wishbone Data Strobe
wire          wbm_write;      //Wishbone Write Access 


parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 16;

gpmc_to_wishbone #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH))
gpmc_to_wishbone_controller (
    //System Clock and Reset
    .clk(clk),
    .reset(reset),
    
    // GPMC INTERFACE
    .gpmc_ad(gpmc_ad),             //Data Multiplexed with Address [16:1]
    .gpmc_advn(gpmc_advn),         //Address Valid Enable(Address capture on ADVn rising edge)
    .gpmc_csn1(gpmc_csn1),         //Chip Select
    .gpmc_wein(gpmc_wein),         //Write Enable (write access only)
    .gpmc_oen(gpmc_oen),           //Output Enable (read access only)
    .gpmc_clk(gpmc_clk),           //GPMC clock

    //Wishbone Interface Signals
    .wbm_address(wbm_address),     //Wishbone Address Bus
    .wbm_readdata(wbm_readdata),   //Wishbone Data Bus for Read Access
    .wbm_writedata(wbm_writedata), //Wishbone Bus for Write Access
    .wbm_ack(wbm_ack),             //Wishbone Acknowledge Signal
    .wbm_cycle(wbm_cycle),         //Wishbone Bus Cycle in Progress 
    .wbm_strobe(wbm_strobe),       //Wishbone Data Strobe
    .wbm_write(wbm_write)          //Wishbone Write Access 
);

always #2.5 clk = ~clk;
always #20 gpmc_clk = ~gpmc_clk;

initial begin
    $display($time, "   ::   ------------- Starting Simulation of GPMC to Wishbone Wrapper --------------");
    $dumpfile("a.vcd");
    $dumpvars(0, tb_gpmc_to_wishbone); 
end

// Generating Clocks:
initial begin
    clk = 0;
    gpmc_clk = 0;
    reset = 1;

    #30
    gpmc_csn1 = 0;
    gpmc_wein = 1;
    gpmc_oen  = 1;
    gpmc_advn = 0;
    gpmc_ad_reg  = 16'hFFFF;
    #30
    gpmc_advn = 1;
    gpmc_wein = 0;
    gpmc_ad_reg = 16'hDEAD;
    #30
    gpmc_wein = 1;
    gpmc_advn = 0;
    gpmc_ad_reg  = 16'hAAAA;
    #50
    gpmc_advn = 1;
    gpmc_oen  = 0;   
    wbm_readdata  = 16'hF0F0;
    #50
    gpmc_csn1 = 1;
    #400
    $finish;
end

assign gpmc_ad = (gpmc_oen) ? gpmc_ad_reg : 16'bz;

endmodule