////////////////////////////////////////////////////////////// 
/*
//   Function of IP: Wishbone Intercon
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
//
//                |--------------------------|
//                |  1 Master to 2 Slaves    |
//                |--------------------------|
//   WIshbone share bus intercon
//   - Based on multiplexors
//   - 1 Master to 2 slaves
//   - Partial Decoding
//
//    Wishbone Memmap
//        Slave 0:  0x0000
//        Slave 1:  0x0040
///////////////////////////////////////////////////////////*/


module wb_intercon #(
    // Wishbone Slave Number and address info
    parameter wb_decoder_width = 8,     // Decoder Widht
    parameter wb_no_slaves = 2,         // Number of Slaves
    parameter wb_slave_0 = 8'h00,
    parameter wb_slave_1 = 8'h40,

    parameter ADDR_WIDTH = 8,      // Parameters for Address and Data
	parameter DATA_WIDTH = 16
)(
    // Clock and Reset
	input  wire clk,
	input  wire reset,

	// Wishbone Master in
	input  wire [ADDR_WIDTH-1:0]  wbm_address,    //Wishbone Address Bus 
	input  wire [DATA_WIDTH-1:0]  wbm_writedata,  //Wishbone read data
	output wire [DATA_WIDTH-1:0]  wbm_readdata,   //Wishbone write data
	input  wire wbm_write,     //Wishbone Write(High = Write)
	input  wire wbm_cycle,     //Wishbone Bus Cycle in Progress 
    input  wire wbm_strobe,    //Wishbone Strobe
	output wire wbm_ack,        //Wishbone Acknowledge Signal from Slave

    //Wishbone Intercon out
    input wire [DATA_WIDTH-1:0]  wbi_readdata_0,
    input wire [DATA_WIDTH-1:0]  wbi_readdata_1,
    output wire [DATA_WIDTH-1:0]  wbi_writedata,
    output wire [ADDR_WIDTH-1:0]  wbi_address,
    output wire wbi_write,
    output wire [wb_no_slaves-1:0] wbi_strobe ,
    output wire [wb_no_slaves-1:0] wbi_cycle ,
    input wire [wb_no_slaves-1:0] wbi_ack 
);

reg [wb_no_slaves-1:0] wbi_cs;
reg [DATA_WIDTH-1:0]  wbm_readdata_muxed;
reg wbm_ack_muxed;

/*
    --------- Partial Address Decoder in Verilog. ---------
*/
always @ (posedge clk) begin
    if (wbi_address < wb_slave_1) begin
        wbi_cs <= 2'b01;
    end else if (wbi_address > wb_slave_1) begin
        wbi_cs <= 2'b10;    
    end else begin 
        wbi_cs <= 2'b00;
    end
end

/*
   --------- NON Muxed Signals --------------
*/

//Assigning Strobe to the Slaves
assign wbi_strobe[0] = wbi_cs[0] & wbm_strobe;
assign wbi_strobe[1] = wbi_cs[1] & wbm_strobe;

//Assigning Cycle to the Slaves
assign wbi_cycle[0] = wbi_cs[0]  & wbm_cycle;
assign wbi_cycle[1] = wbi_cs[1]  & wbm_cycle;

//Write Signal
assign wbi_write = wbm_write;

//Data and Address
assign wbi_writedata = wbm_writedata;
assign wbi_address = wbm_address;

/*
    --------- Muxed Signals ---------------
*/
always @ (posedge clk) begin
    if(!wbi_write && wbi_strobe[0]) begin
        wbm_readdata_muxed <=  wbi_readdata_0;
        wbm_ack_muxed <= wbi_ack[0];
    end else if (!wbi_write && wbi_strobe[1]) begin
        wbm_readdata_muxed <=  wbi_readdata_1;
        wbm_ack_muxed <= wbi_ack[1];
    end
end

assign wbm_readdata = wbm_readdata_muxed;
assign wbm_ack = wbm_ack_muxed;

endmodule

