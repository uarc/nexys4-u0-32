`include "vga_controller/vga.v"
`include "ascii_pixel.v"

module vga_ascii_terminal(
    clk,
    reset,
    white,
    h_sync,
    v_sync,

    add_char,
    char_value
    );
    parameter WIDTH_BITS = 7;
    parameter WIDTH = 80;
    parameter HEIGHT_BITS = 6;
    parameter HEIGHT = 60;
    parameter BLINK_BITS = 27;
    parameter BLINK_PERIOD = 100000000;
    parameter VGA_DOWNCLOCK_BITS = 2;
    parameter VGA_DOWNCLOCK_PERIOD = 1 << VGA_DOWNCLOCK_BITS;

    input clk, reset;
    output white, h_sync, v_sync;

    input add_char;
    input [6:0] char_value;

    wire [9:0] h_counter_next, v_counter_next;
    wire will_display;
    reg [6:0] char_display;

    reg [BLINK_BITS-1:0] blink_counter;
    reg [VGA_DOWNCLOCK_BITS-1:0] vga_counter;

    reg [6:0] characters [WIDTH*HEIGHT-1:0];
    reg [HEIGHT_BITS-1:0] row_bottom;
    reg [WIDTH_BITS-1:0] row_columns [HEIGHT-1:0];

    vga vga(
        .clk(vga_counter == 0),
        .reset,
        .h_counter_next,
        .h_sync,
        .v_counter_next,
        .v_sync,
        .will_display
        );

    ascii_pixel ascii_pixel(
        .char(char_display),
        .xpos(h_counter_next[2:0]),
        .ypos(v_counter_next[2:0]),
        .white
        );

    int i;

    always @* begin
        if (v_counter_next[9:3] == row_bottom && h_counter_next[9:3] == row_columns[row_bottom])
            // Display ESC, which is a block, or NULL, which is the same as space.
            char_display = (blink_counter < BLINK_PERIOD / 2) ? 7'h7F : 7'h0;
        else if (v_counter_next[9:3] > row_bottom)
            char_display = characters[(v_counter_next[9:3] - row_bottom - 1) * WIDTH + h_counter_next[9:3]];
        else
            char_display = characters[(v_counter_next[9:3] + ((HEIGHT-1) - row_bottom)) * WIDTH + h_counter_next[9:3]];
    end

    always @(posedge clk) begin
        if (reset) begin
            vga_counter <= 0;
            for (i = 0; i < WIDTH; i = i + 1)
                row_columns[i] <= 0;
            row_bottom <= 0;
            for (i = 0; i < WIDTH*HEIGHT; i = i + 1)
                characters[i] <= 0;
            blink_counter <= 0;
        end else begin
            if (vga_counter == 0)
                vga_counter <= VGA_DOWNCLOCK_PERIOD - 1;
            else
                vga_counter <= vga_counter - 1;
            if (blink_counter == 0)
                blink_counter <= BLINK_PERIOD - 1;
            else
                blink_counter <= blink_counter - 1;
            if (add_char) begin
                case (char_value)
                    // Backspace
                    7'h08: begin
                        characters[row_columns[row_bottom] + row_bottom * WIDTH] <= 0;
                        if (row_columns[row_bottom] == 0) begin
                            if (row_bottom == 0)
                                row_bottom <= HEIGHT - 1;
                            else
                                row_bottom <= row_bottom - 1;
                        end else begin
                            row_columns[row_bottom] <= row_columns[row_bottom] - 1;
                        end
                    end
                    // Newline
                    7'h0A: begin
                        if (row_bottom == HEIGHT-1) begin
                            row_bottom <= 0;
                            row_columns[0] <= 0;
                            for (i = 0; i < WIDTH; i = i + 1)
                                characters[i] <= 0;
                        end else begin
                            row_bottom <= row_bottom + 1;
                            row_columns[row_bottom + 1] <= 0;
                            for (i = 0; i < WIDTH; i = i + 1)
                                characters[(row_bottom + 1) * WIDTH + i] <= 0;
                        end
                    end
                    // All other characters
                    default: begin
                        characters[row_columns[row_bottom] + row_bottom * WIDTH] <= char_value;
                        if (row_columns[row_bottom] == WIDTH-1) begin
                            if (row_bottom == HEIGHT-1) begin
                                row_bottom <= 0;
                                row_columns[0] <= 0;
                                for (i = 0; i < WIDTH; i = i + 1)
                                    characters[i] <= 0;
                            end else begin
                                row_bottom <= row_bottom + 1;
                                row_columns[row_bottom + 1] <= 0;
                                for (i = 0; i < WIDTH; i = i + 1)
                                    characters[(row_bottom + 1) * WIDTH + i] <= 0;
                            end
                        end else begin
                            row_columns[row_bottom] <= row_columns[row_bottom] + 1;
                        end
                    end
                endcase
            end
        end
    end
endmodule
