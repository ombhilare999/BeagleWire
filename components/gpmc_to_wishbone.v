/////////////////////////////////////////////////////////////
//   Function of IP: GPMC to Wishbone Conversion
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

`define SIM

`ifdef SIM
    `include "cells_sim.v"
`endif 

module gpmc_to_wishbone 
(
    //System Clock and Reset
    input           clk,            //FPGA Clock
    input           reset,          //Master Reset for Wishbone Bus
    
    // GPMC INTERFACE 
    input           gpmc_clk,       //GPMC clock
    inout  [15:0]   gpmc_ad,        //Data Multiplexed with Address
    input           gpmc_advn,      //ADVN = Low :: gpmc_ ad = Address and ADVN = high :: gpmc_ ad = Data
    input           gpmc_csn1,      //Chip Select(Low - On)
    input           gpmc_wein,      //Low = write operation
    input           gpmc_oen,       //Low = Read Operation
    
    //Wishbone Interface Signals
    input [15:0]    wbm_readdata,   //Wishbone ReadData (The data needs to send to BBB)
    output [15:0]   wbm_writedata,  //Wishbone Bus for Write Access (The data from blocks)
    output [15:0]   wbm_address,    //Wishbone Address Bus for Read/Write Data
    output          wbm_write,      //Wishbone Write(High = Write)
    output          wbm_strobe,     //Wishbone Data Strobe(Valid Data Transfer)
    output          wbm_cycle,      //Wishbone Bus Cycle in Progress 
    input           wbm_ack         //Wishbone Acknowledge Signal from Slave
);

// Macros for Address and Data
parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 16;

// Variables for the bridge
reg  [ADDR_WIDTH-1:0] address_bridge;       
reg  [DATA_WIDTH-1:0] write_data_bridge;
wire [DATA_WIDTH-1:0] read_data_bridge;

reg csn_bridge;
reg wen_bridge;
reg oen_bridge;

// Variables for tristate buffer
reg [ADDR_WIDTH-1:0] gpmc_latch_ad;
wire [DATA_WIDTH-1:0] gpmc_latch_data;

// Variables for Dual flop synchronizer stage 1
reg csn_first_stage;
reg wen_first_stage;
reg oen_first_stage;
reg [ADDR_WIDTH-1:0] address_first_stage;
reg [DATA_WIDTH-1:0] writedata_first_stage;

// Variables for Dual flop synchronizer stage 2
reg csn_final;
reg wen_final;
reg oen_final;
reg [ADDR_WIDTH-1:0] address_final;
reg [DATA_WIDTH-1:0] writedata_final;

////////////////////////////////////////////////////////////////////////
//  Tri-State buffer control
//  The Data Multiplexed with Address [16:1] on gpmc_ad bus
//
// (gpmc_oen)data-control _______
//                          _____|______
//   gpmc_ad ------------->| I   L   Q |-------------> gpmc_latch_ad
//                 |       |           |
//                 |       |___________|
//                 |
//                 |---------------------------------> gpmc_latch_data
//
//  Verilog Implementation of SB_IO peripheral
//assign gpmc_ad = data_control ? gpmc_latch_ad : 1'bz;
//assign gpmc_latch_data = gpmc_ad;
////////////////////////////////////////////////////////////////////

SB_IO # (
    .PIN_TYPE(6'b1010_01),
    .PULLUP(1'b 0)
) gpmc_ad_io [15:0] (
    .PACKAGE_PIN(gpmc_ad),
    .OUTPUT_ENABLE(!gpmc_csn1 && gpmc_advn && !gpmc_oen && gpmc_wein && reset),
    .D_OUT_0(gpmc_latch_ad),
    .D_IN_0(gpmc_latch_data)
);

initial begin
    address_bridge     <= 0;
    csn_bridge         <= 1'b1;
    wen_bridge         <= 1'b1;
    oen_bridge         <= 1'b1;
end


// Latching the address with reset considered.
always @ (negedge gpmc_clk or reset) begin
    if (reset == 1) begin
        if (!gpmc_csn1 && !gpmc_advn && gpmc_wein && gpmc_oen) begin
            address_bridge <= gpmc_latch_data;
        end
    end
    else begin
        address_bridge   <= 0;
    end
end

// Bridging the control signals with reset considered
// Signals fetched on the negative edge of gpmc clk

always @ (negedge gpmc_clk or reset)
begin
    if (reset == 1) 
    begin
        csn_bridge  <= gpmc_csn1;
		wen_bridge  <= gpmc_wein;
		oen_bridge  <= gpmc_oen;
        write_data_bridge <= gpmc_latch_data;
    end
    else
    begin
        csn_bridge <= 1'b1;
		wen_bridge <= 1'b1;
		oen_bridge <= 1'b1;
        write_data_bridge <= 0;
    end
end

///////////////////////////////////////////////
// Dual Flop synchronizer 
///////////////////////////////////////////////
always @(posedge clk)
begin
    if (reset == 1) 
    begin
    // Dual flop synchronizer stage 1  
        csn_first_stage        <= csn_bridge;
        wen_first_stage        <= wen_bridge;
        oen_first_stage        <= oen_bridge;
        address_first_stage    <= address_bridge;
        writedata_first_stage  <= write_data_bridge;

    // Dual flop synchronizer stage 2  
        csn_final              <= csn_first_stage;
        wen_final              <= wen_first_stage;
        oen_final              <= oen_first_stage;
        address_final          <= address_first_stage;
        writedata_final        <= writedata_first_stage; 

        gpmc_latch_ad          <= read_data_bridge;  
    end
    else 
    begin
        csn_final   <= 1'b1;
        wen_final   <= 1'b1;
        oen_final   <= 1'b1;
        address_final  <= 1'b0;
        writedata_final<= 1'b0; 
    end
end

// Assigning the Data
assign wbm_write        = (!wen_final &&  !csn_final);  //Active High Signal. HIGH = Write Going
assign wbm_strobe       = (!csn_final && (wen_final || !oen_final)); //Valid Data
assign wbm_cycle        = (!wen_final &&  !csn_final && !oen_final); //Cycle going or not 

assign wbm_address      =  address_final;
assign wbm_writedata    = writedata_final;
assign read_data_bridge = (!wbm_write) ? wbm_readdata : 16'bz; 

endmodule