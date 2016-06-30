module top(
    clk,
    switches,
    leds
);
    input clk;
    input [15:0] switches;
    output reg [15:0] leds;
    
    always @(posedge clk)
        leds <= switches;
endmodule
