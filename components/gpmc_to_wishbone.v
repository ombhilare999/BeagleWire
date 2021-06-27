/////////////////////////////////////////////////////////////
//   Function of IP: GPMC to Wishbone Conversion
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

module gpmc_to_wishbone 
(
    //System Clock and Reset
    input           clk,
    input         reset,
    
    // GPMC INTERFACE
    inout  [15:0]   gpmc_ad,        //Data Multiplexed with Address [16:1]
    input           gpmc_advn,      //Address Valid Enable(Address capture on ADVn rising edge)
    input           gpmc_csn1,      //Chip Select
    input           gpmc_wein,      //Write Enable (write access only)
    input           gpmc_oen,       //Output Enable (read access only)
    input           gpmc_clk,       //GPMC clock

    //Wishbone Interface Signals
    input [15:0]    wbm_address,    //Wishbone Address Bus
    input [15:0]    wbm_readdata,   //Wishbone Data Bus for Read Access
    output [15:0]   wbm_writedata,  //Wishbone Bus for Write Access
    input           wbm_ack,        //Wishbone Acknowledge Signal
    input           wbm_cycle,      //Wishbone Bus Cycle in Progress 
    output          wbm_strobe,     //Wishbone Data Strobe
    output          wbm_write       //Wishbone Write Access 
);

// Macros for Address and Data
parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 16;

// Variables for the bridge
reg [ADDR_WIDTH-1:0] address_bridge;
reg [DATA_WIDTH-1:0] write_data_bridge;
wire [DATA_WIDTH-1:0] read_data_bridge;

reg csn_bridge;
reg wen_bridge;
reg oen_bridge;
reg data_control;

// Variables for tristate buffer

reg [ADDR_WIDTH-1:0] gpmc_latch_address;
reg [DATA_WIDTH-1:0] gpmc_latch_data;

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
//   gpmc_ad ------------->| I   L   Q |-------------> gpmc_latch_address
//                 |       |           |
//                 |       |___________|
//                 |
//                 |---------------------------------> gpmc_latch_data
//
//  Verilog Implementation of SB_IO peripheral
//  assign flash_io0 = flash_io0_oe ? flash_io0_do : 1'bz;
//  assign flash_io0_di = flash_io0;
////////////////////////////////////////////////////////////////////


SB_IO # (
    .PIN_TYPE(6'b1010_01),
    .PULLUP(1'b 0)
) gpmc_ad_io [15:0] (
    .PACKAGE_PIN(gpmc_ad),
    .OUTPUT_ENABLE(data_control),
    .D_OUT_0(gpmc_latch_address),
    .D_IN_0(gpmc_latch_data)
);

// Latching the address with reset considered.
always @ (negedge gpmc_clk or reset)
begin
    if (!reset) 
    begin
        data_control <= gpmc_oen;
        if (!gpmc_advn)         //Latches Input On Know state
            address_bridge <= gpmc_latch_address;
    end
    else 
    begin
        data_control     <= 1'b1;
        address_bridge   <= 0;
    end
end

always @ (negedge gpmc_clk or reset)
begin
    if (!reset) 
    begin
        csn_bridge  <= gpmc_csn1;
		wen_bridge  <= gpmc_wein;
		oen_bridge  <= gpmc_oen;
        gpmc_latch_data   <= read_data_bridge;
        write_data_bridge <= gpmc_latch_address;
    end
    else
    begin
        csn_bridge <= 1'b1;
		wen_bridge <= 1'b1;
		oen_bridge <= 1'b1;
        gpmc_latch_data <= 0;
        write_data_bridge <= 0;
    end
end

always @ (posedge clk or reset)
begin
    if (!reset) 
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
    end
    else 
    begin
        csn_final   <= 1'b1;
        wen_final   <= 1'b1;
        oen_final   <= 1'b1;
        address_final  <= 1'b1;
        writedata_final<= 1'b1; 
    end
end

assign read_data_bridge = wbm_readdata;
assign wbm_address      = address_final;
assign wbm_writedata    = writedata_final;
assign wbm_strobe       = (!csn_final && (wen_final || !oen_final));
assign wbm_cycle        = (!wen_final &&  !csn_final && !oen_final);
assign wbm_write        = (!wen_final &&  !csn_final);
endmodule