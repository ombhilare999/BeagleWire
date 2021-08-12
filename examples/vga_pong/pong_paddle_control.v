////////////////////////////////////////////////////////////////////////////////
//   Module Name: vga_test_pattern_top.v
//  Dependencies: 25 MHz Clock.
//          Info: Pong Paddle Control
//                
////////////////////////////////////////////////////////////////////////////////


module pong_paddle_control
#(
    parameter c_player_paddle_x = 0,
    parameter c_paddle_height = 6,
    parameter c_game_height = 30
)(
    input i_clk,
    input [5:0] i_col_count_div,
    input [5:0] i_row_count_div,
    input i_paddle_up,
    input i_paddle_down,
    output reg o_draw_paddle,
    output reg [5:0] o_paddle_y
);

// Set the Speed of the paddle movement.  
// In this case, the paddle will move one board game unit
// every 50 milliseconds that the button is held down.
parameter c_paddle_speed = 1250000;

reg [31:0] r_paddle_count = 0;

// ^ is xor
// Only allow paddle if one of them is presed
wire w_paddle_count_en = i_paddle_up ^ i_paddle_down;

always @(posedge i_clk) begin
    if (w_paddle_count_en == 1'b1) begin
        if (r_paddle_count == c_paddle_speed) begin
            r_paddle_count <= 0;
        end else begin
            r_paddle_count <= r_paddle_count + 1;
        end
    end

    // Updating the paddle location:
    if (i_paddle_up == 1'b1 && r_paddle_count == c_paddle_speed && o_paddle_y !== 0) begin
        o_paddle_y <= o_paddle_y - 1;
    end else if (i_paddle_down == 1'b1 && r_paddle_count == c_paddle_speed && o_paddle_y !== c_game_height-c_paddle_height-1) begin
        o_paddle_y <= o_paddle_y + 1;
    end 
end


// Draw the paddle location:
always @(posedge i_clk) begin
    // Vertical position is fixed
    // Row will be changing

    if (i_col_count_div == c_player_paddle_x && i_row_count_div >= o_paddle_y && i_row_count_div <= o_paddle_y + c_paddle_height) begin
        o_draw_paddle <= 1'b1;
    end else begin 
        o_draw_paddle <= 1'b0;
    end 
end

endmodule
