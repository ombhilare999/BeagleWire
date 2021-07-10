/////////////////////////////////////////////////////////////
//   Function of IP: Control Bar Graph with wishbone
//   Author: Omkar Bhilare
//   Email: omkarbhilare45@gmail.com
/////////////////////////////////////////////////////////////

`default_nettype none

module bar_graph_wb #(
	parameter ADDR_WIDTH = 1,   // Parameters for Address and Data
	parameter DATA_WIDTH = 16
)(
    // Clock and Reset
	input  wire clk,
	input  wire reset,

	// Leds
	output wire [7:0] bar_graph,      //LEDs on BeagleWire

	// Wishbone interface
	input  wire [ADDR_WIDTH-1:0]  wbs_address,    //Wishbone Address Bus 
	input  wire [DATA_WIDTH-1:0]  wbs_writedata,  //Wishbone read data
	output wire [DATA_WIDTH-1:0]  wbs_readdata,   //Wishbone write data
	input  wire wbs_strobe,     //Wishbone Strobe
	input  wire wbs_write,     //Wishbone Write(High = Write)
	input  wire wbs_cycle,     //Wishbone Bus Cycle in Progress 
	output wire wbs_ack        //Wishbone Acknowledge Signal from Slave
);

reg [7:0] mem;
reg [7:0] wbs_readdata_reg;
reg wbs_ack_reg;

always @(posedge clk) begin
	if (~reset) begin
		mem[7:0] <= 0;
		wbs_readdata_reg  <= 0;
	end else if (wbs_write && wbs_strobe &&  wbs_cycle) begin
        mem[7:0] <= wbs_writedata[7:0];
		wbs_ack_reg <= 1'b1;
	end else if (!wbs_write && wbs_strobe && wbs_cycle) begin
		wbs_readdata_reg <= mem[7:0];
	end  
end

assign wbs_readdata = wbs_readdata_reg;
assign bar_graph = mem[7:0];
assign wbs_ack = wbs_cycle;

endmodule