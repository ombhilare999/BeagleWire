////////////////////////////////////////////////////////////////////////////////
//   Module Name: top.v
//  Dependencies: 25 MHz Clock.
//          Info: Take input a clock and switches input
//               
////////////////////////////////////////////////////////////////////////////////


module top
(
    //Main Clock and leds
    input i_clk,
    output [3:0] led,

    //Switches Input:
    input pmod_sw, 
    input encoder_btn,
    input encoder_b,  
    input encoder_a  
);

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
    wire debounced_a, debounced_b, debounced_enc_btn;

    debounce_switch switch_1
    (
        .i_clk(i_clk_24),
        .i_switch(encoder_a),
        .o_switch(debounced_a)
    );

    debounce_switch switch_2
    (
        .i_clk(i_clk_24),
        .i_switch(encoder_b),
        .o_switch(debounced_b)
    );

    debounce_switch switch_3
    (
        .i_clk(i_clk_24),
        .i_switch(encoder_btn),
        .o_switch(debounced_enc_btn)
    );

    // State machine enumerations
    parameter IDLE     = 4'b0000;
    parameter L1       = 4'b0001;
    parameter L2       = 4'b0010;
    parameter L3       = 4'b0011;
    parameter SUBTRACT = 4'b0100;
    parameter R1       = 4'b0101;
    parameter R2       = 4'b0110;
    parameter R3       = 4'b0111;
    parameter ADD      = 4'b1000;

    reg [3:0] state = IDLE;
    reg [3:0] count;

    always @(posedge i_clk_24) begin

        case(state)
        
            IDLE: begin
                if (debounced_a == 0) begin
                    state <= L1;
                end else if (debounced_b == 0) begin
                    state <= R1;
                end
            end

            L1: begin
                if (debounced_b == 0) begin
                    state <= L2;
                end else if (debounced_a == 1) begin
                    state <= IDLE;
                end                
            end

            L2: begin
                if (debounced_a == 1) begin
                    state <= L3;
                end else if (debounced_b == 1) begin
                    state <= L1;
                end                
            end

            L3: begin
                if (debounced_b == 1) begin
                    state <= SUBTRACT;
                end else if (debounced_a == 0) begin
                    state <= L2;
                end                
            end

            SUBTRACT: begin
                state <= IDLE;
                count <= count - 1'b1;
            end

            R1: begin
                if (debounced_a == 0) begin
                    state <= R2;
                end else if (debounced_b == 1) begin
                    state <= IDLE;
                end                
            end

            R2: begin
                if (debounced_b == 1) begin
                    state <= R3;
                end else if (debounced_a == 1) begin
                    state <= R1;
                end                
            end

            R3: begin
                if (debounced_a == 1) begin
                    state <= ADD;
                end else if (debounced_b == 0) begin
                    state <= R2;
                end                
            end

            ADD: begin
                state <= IDLE;
                count <= count + 1'b1;
            end
        endcase 
    end
    
    assign led = count;
endmodule

