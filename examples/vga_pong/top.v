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
    output [3:0] led,

    //Start Switch:
    input start_switch,

	//Player Switch Input
	input i_switch_1,
	input i_switch_2,
    input i_switch_3,	
    input i_switch_4,
	
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
    output  o_VGA_blue_2
);

    //Parameter Needed:
    parameter VIDEO_WIDTH =    3;
    parameter TOTAL_COLS  =  800;
    parameter TOTAL_ROWS  =  525;
    parameter ACTIVE_COLS =  640;
    parameter ACTIVE_ROWS =  480;  

    // Common VGA Signals
    wire w_hsync_vga, w_vsync_vga;
    wire w_hsync_porch, w_vsync_porch;
    wire w_hsync_pong, w_vsync_pong;

    wire [VIDEO_WIDTH-1:0]   w_red_video_pong,   w_red_Porch;
    wire [VIDEO_WIDTH-1:0]   w_green_video_pong, w_green_Porch;
    wire [VIDEO_WIDTH-1:0]   w_blue_video_pong,  w_blue_Porch;
	
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
	
    // Debounce Switches
    wire w_switch_1, w_switch_2, w_switch_3, w_switch_4;

    debounce_switch switch_1
    (
        .i_clk(i_clk_24),
        .i_switch(i_switch_1),
        .o_switch(w_switch_1)
    );

    debounce_switch switch_2
    (
        .i_clk(i_clk_24),
        .i_switch(i_switch_2),
        .o_switch(w_switch_2)
    );

    debounce_switch switch_3
    (
        .i_clk(i_clk_24),
        .i_switch(i_switch_3),
        .o_switch(w_switch_3)
    );

    debounce_switch switch_4
    (
        .i_clk(i_clk_24),
        .i_switch(i_switch_4),
        .o_switch(w_switch_4)
    );

	
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

    wire [3:0] score;
    assign led = {w_switch_1, w_switch_2, w_switch_3, w_switch_4};

    pong_top 
    #(
        .TOTAL_COLS(TOTAL_COLS),
        .TOTAL_ROWS(TOTAL_ROWS),
        .ACTIVE_COLS(ACTIVE_COLS),
        .ACTIVE_ROWS(ACTIVE_ROWS)
    ) pong_top (
        .i_clk(i_clk_24),
        .i_hsync(w_hsync_vga),
        .i_vsync(w_vsync_vga),
        .i_game_start(start_switch),    //game start button
        
        // Paddle control buttons
        .i_paddle_up_p1(w_switch_1),
        .i_paddle_down_p1(w_switch_2),
        .i_paddle_up_p2(w_switch_3),
        .i_paddle_down_p2(w_switch_4),

        //Output Video
        .score(score),
        .o_hsync(w_hsync_pong),
        .o_vsync(w_vsync_pong),
        .o_red_video(w_red_video_pong),
        .o_green_video(w_green_video_pong),
        .o_blue_video(w_blue_video_pong)
    );

    vga_sync_porch vga_sync_porch
    (
        .i_clk(i_clk_24),
        .i_hsync(w_hsync_pong),
        .i_vsync(w_vsync_pong),

        .i_red_video(w_red_video_pong),
        .i_green_video(w_green_video_pong),
        .i_blue_video(w_blue_video_pong),

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

