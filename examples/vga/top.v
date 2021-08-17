////////////////////////////////////////////////////////////////////////////////
//   Module Name: vga_test_pattern_top.v
//  Dependencies: 25 MHz Clock.
//          Info: Take input a clock and produces Hsync and Vsync Control Signals
//                with 3 bit depth video out.
////////////////////////////////////////////////////////////////////////////////


module top
(
    //Main Clock
    input i_clk,

	//Select Input for Pattern Display
	input sel0,
	input sel1,	
	input sel2,
    //VGA
    output   o_VGA_hsync,
    output   o_VGA_vsync,
    output   o_VGA_red_0,
    output   o_VGA_red_1,
    output   o_VGA_red_2,
    output o_VGA_green_0,
    output o_VGA_green_1,
    output o_VGA_green_2,
    output  o_VGA_blue_0,
    output  o_VGA_blue_1,
    output  o_VGA_blue_2,
);

    //Parameter Needed:
    parameter VIDEO_WIDTH =    3;
    parameter TOTAL_COLS  =  800;
    parameter TOTAL_ROWS  =  525;
    parameter ACTIVE_COLS =  640;
    parameter ACTIVE_ROWS =  480;  

    // Common VGA Signals
    wire w_hsync_vga, w_vsync_vga;
    wire w_hsync_tp, w_vsync_tp;
    wire w_hsync_porch, w_vsync_porch;
    wire [VIDEO_WIDTH-1:0]   w_red_TP,   w_red_Porch;
    wire [VIDEO_WIDTH-1:0] w_green_TP, w_green_Porch;
    wire [VIDEO_WIDTH-1:0]  w_blue_TP,  w_blue_Porch;
	
	// Clock Signals
	

    /*
    icepll -i 100 -o 24

    F_PLLIN:   100.000 MHz (given)
    F_PLLOUT:   24.000 MHz (requested)
    F_PLLOUT:   23.958 MHz (achieved)

    FEEDBACK: SIMPLE
    F_PFD:   33.333 MHz
    F_VCO:  766.667 MHz

    DIVR:  2 (4'b0010)
    DIVF: 22 (7'b0010110)
    DIVQ:  5 (3'b101)

    FILTER_RANGE: 3 (3'b011)
    */

    wire i_clk_24;
    wire lock;

    SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),
    .DIVR(4'b0010),
    .DIVF(7'b0010110),
    .DIVQ(3'b101),
    .FILTER_RANGE(3'b011)
    ) uut (
        .LOCK(lock),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(i_clk_24)
    );
	
	/*Pattern for dispaly
	wire [2:0]i_pattern;
    reg  [2:0]i_pattern_reg;

	always @(sel2 or sel1 or sel0) begin
        case({sel2, sel1, sel0}) 
            3'b000: i_pattern_reg <= 3'b000;
            3'b001: i_pattern_reg <= 3'b001;
            3'b010: i_pattern_reg <= 3'b010;
            3'b011: i_pattern_reg <= 3'b011;
            3'b100: i_pattern_reg <= 3'b100;
            3'b101: i_pattern_reg <= 3'b101;
        endcase 
    end
    */
    
    wire [2:0] i_pattern = {sel2, sel1, sel0};
	 
    //////////////////////////////////////////////////////////////////////////////////////
    // Creating Instants of VGA modules
    //////////////////////////////////////////////////////////////////////////////////////

    vga_sync_pulse vga_sync_pulse
    (
        .i_clk(i_clk_24),
        .o_hsync(w_hsync_vga),
        .o_vsync(w_vsync_vga),
        .o_col_count(),
        .o_row_count()
    );

    test_pattern_gen test_pattern_gen
    (
        .i_clk(i_clk_24),
        .i_pattern(i_pattern),
        .i_hsync(w_hsync_vga),
        .i_vsync(w_vsync_vga),
        .o_hsync(w_hsync_tp),
        .o_vsync(w_vsync_tp),
        .o_red_video(w_red_TP),
        .o_green_video(w_green_TP),
        .o_blue_video(w_blue_TP)
    );

    vga_sync_porch vga_sync_porch
    (
        .i_clk(i_clk_24),
        .i_hsync(w_hsync_tp),
        .i_vsync(w_vsync_tp),
        .i_red_video(w_red_TP),
        .i_green_video(w_green_TP),
        .i_blue_video(w_blue_TP),
        .o_hsync(w_hsync_porch),
        .o_vsync(w_vsync_porch),
        .o_red_video(w_red_Porch),
        .o_green_video(w_green_Porch),
        .o_blue_video(w_blue_Porch)
    );
	

    assign   o_VGA_hsync = w_hsync_porch;
    assign   o_VGA_vsync = w_vsync_porch;

    assign   o_VGA_red_0 = w_red_Porch[0];
    assign   o_VGA_red_1 = w_red_Porch[1];
    assign   o_VGA_red_2 = w_red_Porch[2];

    assign o_VGA_green_0 = w_green_Porch[0];
    assign o_VGA_green_1 = w_green_Porch[1];
    assign o_VGA_green_2 = w_green_Porch[2];

    assign  o_VGA_blue_0 = w_blue_Porch[0];
    assign  o_VGA_blue_1 = w_blue_Porch[1];
    assign  o_VGA_blue_2 = w_blue_Porch[2]; 
endmodule

