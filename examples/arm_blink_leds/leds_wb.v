/////////////////////////////////////////////////////////////
//   Function of IP: Control LEDs using Wishbone
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

`default_nettype none

module leds_wb
(
    // Clock and Reset
	input  wire clk,
	input  wire reset,

	// Leds
	output wire [3:0] led,      //LEDs on BeagleWire

	// Wishbone interface
	input  wire [ADDR_WIDTH-1:0]  wbs_address,    //Wishbone Address Bus 
	input  wire [DATA_WIDTH-1:0]  wbs_writedata,  //Wishbone read data
	output wire [DATA_WIDTH-1:0]  wbs_readdata,   //Wishbone write data
	input  wire wbs_write,     //Wishbone Write(High = Write)
	input  wire wbs_cycle,     //Wishbone Bus Cycle in Progress 
	output wire wbs_ack        //Wishbone Acknowledge Signal from Slave
);

// Parameters for Address and Data
parameter ADDR_WIDTH = 5;
parameter DATA_WIDTH = 16;

//Optional Memory Support
parameter RAM_DEPTH = 1 << ADDR_WIDTH;
reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH];
reg [DATA_WIDTH-1:0] wbs_readdata_reg;

always @(posedge clk) begin
    if (wbs_write && !wbs_cycle && reset) begin
        mem[wbs_address] <= wbs_writedata;
	end else if (!wbs_write && !wbs_cycle && reset) begin
		wbs_readdata_reg <= mem[wbs_address];
	end else if (~reset) begin
		mem[0][3:0] <= 0;
		wbs_readdata_reg  <= 0;
	end
end

assign wbs_readdata = wbs_readdata_reg;
assign led = mem[0][3:0];
assign wbs_ack = wbs_cycle;

endmodule