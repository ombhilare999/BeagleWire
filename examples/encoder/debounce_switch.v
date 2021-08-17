////////////////////////////////////////////////////////////////////////////////
//   Module Name: debounce_switch.v
//  Dependencies: 25 MHz Clock.
//          Info: To debounce the input switch
//                
////////////////////////////////////////////////////////////////////////////////


module debounce_switch
(
    input i_clk,
    input i_switch,
    output o_switch
);

// 10 MS at 25 MHz
parameter wait_period = 50000;
reg [17:0] wait;

reg reg_switch = 1'b1;

always @(posedge i_clk) begin
    if (i_switch !== reg_switch && wait < wait_period) begin
        wait <= wait + 1;
    end else if ( wait == wait_period) begin
        reg_switch <= i_switch;
        wait <= 0;
    end else begin
        wait <= 0;
    end
end

assign o_switch = reg_switch;

endmodule