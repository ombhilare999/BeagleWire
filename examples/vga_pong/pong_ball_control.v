////////////////////////////////////////////////////////////////////////////////
//   Module Name: pong_ball_control.v
//  Dependencies: 25 MHz Clock.
//          Info: Pong Ball Control
//                
////////////////////////////////////////////////////////////////////////////////

module pong_ball_control 
#(
    parameter c_game_width = 40,
    parameter c_game_height = 30
)(
    input i_clk,
    input i_game_active,
    input [5:0] i_col_count_div,
    input [5:0] i_row_count_div,
    output reg o_draw_ball,
    output reg [5:0] o_ball_x = 0,
    output reg [5:0] o_ball_y = 0
);

// Set the Speed of the paddle movement.  
// In this case, the paddle will move one board game unit
// every 50 milliseconds that the button is held down.
parameter c_ball_speed = 1250000;

reg [5:0] r_ball_x_prev = 0;
reg [5:0] r_ball_y_prev = 0;
reg [31:0] r_ball_count = 0;

always @(posedge i_clk) begin
    // at start, ball stays in middle
    if (i_game_active == 1'b0) begin
        o_ball_x <= c_game_width/2;
        o_ball_y <= c_game_height/2;
        r_ball_x_prev <= c_game_width/2 + 1;
        r_ball_y_prev <= c_game_height/2 - 1;
    end else begin
        // update the ball counter continuously 
        if (r_ball_count < c_ball_speed) begin
            r_ball_count <= r_ball_count + 1;
        end else begin
            r_ball_count <= 0;
            //storing last location
            r_ball_x_prev <= o_ball_x;
            r_ball_y_prev <= o_ball_y;

            // When Previous Value is less than current value, ball is moving
            // to right.  Keep it moving to the right unless we are at wall.
            // When Prevous value is greater than current value, ball is moving
            // to left.  Keep it moving to the left unless we are at a wall.
            // Same philosophy for both X and Y.   

            // For x position
            if( (r_ball_x_prev < o_ball_x && o_ball_x == c_game_width-1) || (r_ball_x_prev > o_ball_x && o_ball_x !=0) ) begin
                o_ball_x <= o_ball_x - 1; // Moves the ball to the left
            end else begin
                o_ball_x <= o_ball_x + 1; // Moves the ball to the right 
            end

            // For y position
            if ( (r_ball_y_prev < o_ball_y && o_ball_y == c_game_height-1) || (r_ball_y_prev > o_ball_y && o_ball_y !=0) ) begin
                o_ball_y <= o_ball_y - 1; //Moves the ball up
            end else begin 
                o_ball_y <= o_ball_y + 1; //Moves the ball down
            end

        end
    end
end

// Draw the pong game:
always @(posedge i_clk) begin
    if (i_row_count_div == o_ball_y && i_col_count_div == o_ball_x) begin
        o_draw_ball <= 1'b1;
    end else begin
        o_draw_ball <= 1'b0;
    end
end

endmodule