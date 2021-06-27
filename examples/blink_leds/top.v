module top(input clk, output [3:0] led);

	reg [27:0] counter = 0;
	always @(posedge clk) counter <= counter + 1;

	assign led[0] = counter[27];.
	assign led[1] = counter[27];
	assign led[2] = counter[27];
	assign led[3] = counter[27];
endmodule
