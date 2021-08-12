////////////////////////////////////////////////////////////////////////////////
//   Module Name: vga_test_pattern_top.v
//  Dependencies: 25 MHz Clock.
//          Info: Pong_top module
//                
////////////////////////////////////////////////////////////////////////////////


module pong_top 
#(
    parameter TOTAL_COLS  =  800,
    parameter TOTAL_ROWS  =  525,
    parameter ACTIVE_COLS =  640,
    parameter ACTIVE_ROWS =  480
)(
    input i_clk,
    input i_hsync,
    input i_vsync,
    input i_game_start,    //game start button
    
    // Paddle control buttons
    input i_paddle_up_p1,
    input i_paddle_down_p1,
    input i_paddle_up_p2,
    input i_paddle_down_p2,

    //Output Video
    output reg o_hsync,
    output reg o_vsync,
    output [3:0] o_red_video,
    output [3:0] o_green_video,
    output [3:0] o_blue_video
);

//local parameters

parameter c_game_width = 40;
parameter c_game_height = 30;
parameter c_score_limit = 9;
parameter c_paddle_height = 6;

// player 1's paddle will be fixed in col 1
// player 2's paddle will be fixed in last col
parameter c_paddle_col_p1 = 0;
parameter c_paddle_col_p2 = c_game_height - 1;

// State machine enumerations
parameter idle    = 3'b000;
parameter running = 3'b001;
parameter p1_wins = 3'b010;
parameter p2_wins = 3'b011;
parameter cleanup = 3'b100;

reg [2:0] r_sm_main = idle;

wire w_hsync, w_vsync;
wire [9:0] w_col_count, w_row_count;

wire w_draw_paddle_p1, w_draw_paddle_p2;
wire [5:0] w_draw_y_p1, w_draw_y_p2;

wire w_draw_ball, w_draw_any;
wire [5:0] w_ball_x, w_ball_y;

reg [3:0] r_p1_score = 0;
reg [3:0] r_p2_score = 0;

// Divided version of the Row/Col Counters
// Allows us to make the board 40x30
wire [5:0] w_col_count_div, w_row_count_div;

wire w_game_active;

//Creating Instant
sync_count sync_count_pong
#(
    .TOTAL_COLS(TOTAL_COLS),
    .TOTAL_ROWS(TOTAL_ROWS)
)
(
    .i_clk(i_clk),
    .i_hsync(i_hsync),
    .i_vsync(i_vsync),
    .o_hsync(w_hsync),
    .o_vsync(w_vsync),
    .o_col_count(w_col_count),
    .o_row_count(w_row_count)
);

// Register sync to align output data

always @(posedge i_clk) begin
    o_hsync <= w_hsync;
    o_vsync <= w_vsync;
end

// drop 4 LSBS which divides the number by 16
assign w_col_count_div = w_col_count[9:4];
assign w_row_count_div = w_row_count[9:4];

// Paddle control for player 1:

pong_paddle_control pong_paddle_control_p1
#(
    .c_player_paddle_x(c_paddle_col_p1),
    .c_paddle_height(c_paddle_height),
    .c_game_height(c_game_height)
)(
    .i_clk(i_clk),
    .i_col_count_div(w_col_count_div),
    .i_row_count_div(w_row_count_div),
    .i_paddle_up(i_paddle_up_p1),
    .i_paddle_down(i_paddle_down_p1),
    .o_draw_paddle(w_draw_paddle_p1),
    .o_paddle_y(w_draw_y_p1)
);

pong_paddle_control pong_paddle_control_p2
#(
    .c_player_paddle_x(c_paddle_col_p2),
    .c_paddle_height(c_paddle_height),
    .c_game_height(c_game_height)
)(
    .i_clk(i_clk),
    .i_col_count_div(w_col_count_div),
    .i_row_count_div(w_row_count_div),
    .i_paddle_up(i_paddle_up_p2),
    .i_paddle_down(i_paddle_down_p2),
    .o_draw_paddle(w_draw_paddle_p2),
    .o_paddle_y(w_draw_y_p2)
);


pong_ball_control pong_ball_control
#(
    .c_game_width(c_game_width),
    .c_game_height(c_game_height)
)(
    .i_clk(i_clk),
    .i_game_active(w_game_active),
    .i_col_count_div(w_col_count_div),
    .i_row_count_div(w_row_count_div),
    .o_draw_ball(w_draw_ball),
    .o_ball_x(w_ball_x),
    .o_ball_y(w_ball_y)
);

endmodule