`include "scancode_ascii.v"

module ps2_ascii(
    clk,
    reset,
    ps2_clk,
    ps2_data,
    new_code,
    ascii_code
    );
    parameter DEBOUNCE_5US_WAIT_HOST_BITS = 9;
    // This should be set to the amount of host clock cycles in 5 microseconds.
    parameter DEBOUNCE_5US_WAIT_HOST_CYCLES = (1 << DEBOUNCE_5US_WAIT_HOST_BITS) - 1;
    parameter DEBOUNCE_50US_WAIT_HOST_BITS = 12;
    // This should be set to the amount of host clock cycles in 50 microseconds.
    parameter DEBOUNCE_50US_WAIT_HOST_CYCLES = (1 << DEBOUNCE_50US_WAIT_HOST_BITS) - 1;

    input clk, reset, ps2_clk, ps2_data;
    output reg new_code;
    output reg [6:0] ascii_code;

    reg [DEBOUNCE_5US_WAIT_HOST_BITS-1:0] debounce_counter;
    reg [DEBOUNCE_50US_WAIT_HOST_BITS-1:0] reset_counter;
    reg [3:0] code_counter;
    reg [10:0] serial_buffer;
    reg last_code_extended;
    reg ignore_next_code;
    reg left_shift_mode;
    reg right_shift_mode;

    wire [7:0] latest_code;
    wire [7:0] scancode_ascii_code;
    wire scancode_ascii_valid;

    assign latest_code = serial_buffer[8:1];

    scancode_ascii scancode_ascii(
        .extended(last_code_extended),
        .shift_mode(left_shift_mode || right_shift_mode),
        .scan_code(latest_code),
        .ascii_code(scancode_ascii_code),
        .valid(scancode_ascii_valid));

    always @(posedge clk) begin
        if (reset) begin
            // The debounce counter needs to be set to 0 so we get triggered on a positive edge.
            debounce_counter <= 0;
            reset_counter <= DEBOUNCE_50US_WAIT_HOST_CYCLES;
            code_counter <= 0;
            last_code_extended <= 1'b0;
            ignore_next_code <= 1'b0;
            left_shift_mode <= 1'b0;
            right_shift_mode <= 1'b0;
        end else begin
            if (ps2_clk) begin
                // If we have seen 1 for 50 microseconds, reset the PS/2 state except for the extended code reg.
                if (reset_counter == 0) begin
                    debounce_counter <= 0;
                    code_counter <= 0;
                    new_code <= 1'b0;
                end else begin
                    // Decrease the reset_counter towards 0.
                    reset_counter <= reset_counter - 1;
                    // The debounce counter has completed and we may now read the bit.
                    if (debounce_counter == 1) begin
                        debounce_counter <= 0;
                        // We received 10 bits, thus this is the last bit.
                        if (code_counter == 9) begin
                            // The counter is always reset here.
                            code_counter <= 0;
                            // The parity and start/stop bits are correct.
                            if (((^latest_code) ^ serial_buffer[10]) && !serial_buffer[0] && ps2_data) begin
                                if (latest_code == 8'hE0) begin
                                    last_code_extended <= 1'b1;
                                    ignore_next_code <= 1'b0;
                                    new_code <= 1'b0;
                                end else if (latest_code == 8'hF0) begin
                                    last_code_extended <= 1'b0;
                                    ignore_next_code <= 1'b1;
                                    new_code <= 1'b0;
                                end else if (ignore_next_code) begin
                                    // Actually don't ignore the shift code.
                                    if (latest_code == 8'h12)
                                        // Exit shift mode.
                                        left_shift_mode <= 1'b0;
                                    if (latest_code == 8'h59)
                                        // Exit shift mode.
                                        right_shift_mode <= 1'b0;
                                    last_code_extended <= 1'b0;
                                    ignore_next_code <= 1'b0;
                                    new_code <= 1'b0;
                                end else begin
                                    // Left shift
                                    if (latest_code == 8'h12) begin
                                        left_shift_mode <= 1'b1;
                                        last_code_extended <= 1'b0;
                                        ignore_next_code <= 1'b0;
                                        new_code <= 1'b0;
                                    // Right shift
                                    end else if (latest_code == 8'h59) begin
                                        right_shift_mode <= 1'b1;
                                        last_code_extended <= 1'b0;
                                        ignore_next_code <= 1'b0;
                                        new_code <= 1'b0;
                                    end else if (scancode_ascii_valid) begin
                                        // Send the ASCII code to the output.
                                        ascii_code <= scancode_ascii_code;
                                        new_code <= 1'b1;
                                        last_code_extended <= 1'b0;
                                        ignore_next_code <= 1'b0;
                                    end else begin
                                        // It didn't have a known ASCII value, so just reset everything.
                                        new_code <= 1'b0;
                                        last_code_extended <= 1'b0;
                                        ignore_next_code <= 1'b0;
                                    end
                                end
                            // There is an error with the data.
                            end else begin
                                // TODO: Signal to the PS/2 to resend the code.
                                // Don't send the malformed code to the output.
                                new_code <= 1'b0;
                                last_code_extended <= 1'b0;
                                ignore_next_code <= 1'b0;
                            end
                        // This isn't the last bit, so add it to the buffer.
                        end else begin
                            serial_buffer[code_counter] <= ps2_data;
                            code_counter <= code_counter + 1;
                            new_code <= 1'b0;
                        end
                    end else if (debounce_counter == 0) begin
                        new_code <= 1'b0;
                    end else begin
                        debounce_counter <= debounce_counter - 1;
                        new_code <= 1'b0;
                    end
                end
            end else begin
                debounce_counter <= DEBOUNCE_5US_WAIT_HOST_CYCLES;
                reset_counter <= DEBOUNCE_50US_WAIT_HOST_CYCLES;
                new_code <= 1'b0;
            end
        end
    end
endmodule
