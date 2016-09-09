`include "core0/src/core0.sv"
`include "ps2_ascii/ps2_ascii.v"
`include "vga_ascii_terminal/vga_ascii_terminal.v"

module top(
    clk,
    reset_b,
    PS2Clk,
    PS2Data,
    vgaRed,
    vgaGreen,
    vgaBlue,
    Hsync,
    Vsync
);
  /// The log2 of the word width of the core
  localparam WORD_MAG = 5;
  localparam WORD_WIDTH = 1 << WORD_MAG;
  /// Each set contains WORD_WIDTH amount of buses.
  /// Not all of these buses need to be connected to an actual core.
  localparam UARC_SETS = 1;
  /// Must be less than or equal to UARC_SETS * WORD_WIDTH
  localparam TOTAL_BUSES = 1;
  /// This is the width of the program memory address bus
  localparam PROGRAM_ADDR_WIDTH = 16;
  localparam PROGRAM_SIZE = 1 << PROGRAM_ADDR_WIDTH;
  /// This is the width of the main memory address bus
  localparam MAIN_ADDR_WIDTH = 16;
  localparam MEMORY_SIZE = 1 << MAIN_ADDR_WIDTH;
  /// This is how many DCs fit on the astack
  parameter ASTACK_DEPTH = 64;
  /// This is how many recursions are possible with the cstack
  localparam CSTACK_DEPTH = 64;
  /// This is how many loops can be nested with the lstack
  localparam LSTACK_DEPTH = 7;
  /// Increasing this by 1 doubles the length of the conveyor buffer
  localparam CONVEYOR_ADDR_WIDTH = 4;

  localparam STDIN = 32'h8000_0000;
  localparam STDOUT = 32'h8000_0001;

  input clk, reset_b;
  input PS2Clk, PS2Data;
  output [3:0] vgaRed, vgaGreen, vgaBlue;
  output Hsync, Vsync;

  wire pixel_white;

  reg [7:0] programmem [0:PROGRAM_SIZE-1];
  reg [WORD_WIDTH-1:0] mainmem [0:MEMORY_SIZE-1];

  wire [PROGRAM_ADDR_WIDTH-1:0] programmem_addr;
  reg [(8 + WORD_WIDTH)-1:0] programmem_read_value;
  wire [PROGRAM_ADDR_WIDTH-1:0] programmem_write_addr;
  wire [WORD_WIDTH-1:0] programmem_write_mask;
  wire [WORD_WIDTH-1:0] programmem_write_value;
  wire programmem_we;

  wire [MAIN_ADDR_WIDTH-1:0] mainmem_read_addr;
  wire [MAIN_ADDR_WIDTH-1:0] mainmem_write_addr;
  reg [WORD_WIDTH-1:0] mainmem_read_value;
  wire [WORD_WIDTH-1:0] mainmem_write_value;
  wire mainmem_we;

  wire global_kill;
  wire global_incept;
  wire global_send;
  wire global_stream;
  wire [WORD_WIDTH-1:0] global_data;
  wire [WORD_WIDTH-1:0] global_self_permission;
  wire [WORD_WIDTH-1:0] global_self_address;
  wire [WORD_WIDTH-1:0] global_incept_permission;
  wire [WORD_WIDTH-1:0] global_incept_address;

  // All of the signals for each bus for when this core is acting as the sender
  wire [TOTAL_BUSES-1:0] sender_enables;
  wire [TOTAL_BUSES-1:0] sender_kill_acks;
  wire [TOTAL_BUSES-1:0] sender_incept_acks;
  wire [TOTAL_BUSES-1:0] sender_send_acks;
  wire [TOTAL_BUSES-1:0] sender_stream_acks;

  // All of the signals for each bus for when this core is acting as the receiver
  wire [TOTAL_BUSES-1:0] receiver_enables;
  wire [TOTAL_BUSES-1:0] receiver_kills;
  wire [TOTAL_BUSES-1:0] receiver_kill_acks;
  wire [TOTAL_BUSES-1:0] receiver_incepts;
  wire [TOTAL_BUSES-1:0] receiver_incept_acks;
  wire [TOTAL_BUSES-1:0] receiver_sends;
  wire [TOTAL_BUSES-1:0] receiver_send_acks;
  wire [TOTAL_BUSES-1:0] receiver_streams;
  wire [TOTAL_BUSES-1:0] receiver_stream_acks;
  reg [TOTAL_BUSES-1:0][WORD_WIDTH-1:0] receiver_datas;
  wire [TOTAL_BUSES-1:0][WORD_WIDTH-1:0] receiver_self_permissions;
  wire [TOTAL_BUSES-1:0][WORD_WIDTH-1:0] receiver_self_addresses;
  wire [TOTAL_BUSES-1:0][WORD_WIDTH-1:0] receiver_incept_permissions;
  wire [TOTAL_BUSES-1:0][WORD_WIDTH-1:0] receiver_incept_addresses;

  assign sender_kill_acks = {TOTAL_BUSES{1'b0}};
  assign sender_incept_acks = {TOTAL_BUSES{1'b0}};
  assign sender_stream_acks = {TOTAL_BUSES{1'b0}};

  assign receiver_enables = 1'b1;
  assign receiver_kills = {TOTAL_BUSES{1'b0}};
  assign receiver_incepts = {TOTAL_BUSES{1'b0}};
  assign receiver_streams = {TOTAL_BUSES{1'b0}};
  assign receiver_self_permissions = {(TOTAL_BUSES * WORD_WIDTH){1'b0}};
  assign receiver_self_addresses = {(TOTAL_BUSES * WORD_WIDTH){1'b0}};
  assign receiver_incept_permissions = {(TOTAL_BUSES * WORD_WIDTH){1'b0}};
  assign receiver_incept_addresses = {(TOTAL_BUSES * WORD_WIDTH){1'b0}};

  reg [6:0] character_buffer;
  reg buffered_ascii;
  wire [6:0] ascii_input;
  wire new_ascii;

  assign receiver_sends = buffered_ascii;
  assign sender_send_acks = sender_enables && global_send;

  assign {vgaRed, vgaGreen, vgaBlue} = {12{pixel_white}};

  core0 #(
    .WORD_MAG(WORD_MAG),
    .UARC_SETS(UARC_SETS),
    .TOTAL_BUSES(TOTAL_BUSES),
    .PROGRAM_ADDR_WIDTH(PROGRAM_ADDR_WIDTH),
    .MAIN_ADDR_WIDTH(MAIN_ADDR_WIDTH),
    .ASTACK_DEPTH(ASTACK_DEPTH),
    .CSTACK_DEPTH(CSTACK_DEPTH),
    .LSTACK_DEPTH(LSTACK_DEPTH),
    .CONVEYOR_ADDR_WIDTH(CONVEYOR_ADDR_WIDTH)
  ) core0 (
        clk,
        !reset_b,

        programmem_addr,
        programmem_read_value,
        programmem_write_addr,
        programmem_write_mask,
        programmem_write_value,
        programmem_we,

        mainmem_read_addr,
        mainmem_write_addr,
        mainmem_read_value,
        mainmem_write_value,
        mainmem_we,

        global_kill,
        global_incept,
        global_send,
        global_stream,
        global_data,
        global_self_permission,
        global_self_address,
        global_incept_permission,
        global_incept_address,

        sender_enables,
        sender_kill_acks,
        sender_incept_acks,
        sender_send_acks,
        sender_stream_acks,

        receiver_enables,
        receiver_kills,
        receiver_kill_acks,
        receiver_incepts,
        receiver_incept_acks,
        receiver_sends,
        receiver_send_acks,
        receiver_streams,
        receiver_stream_acks,
        receiver_datas,
        receiver_self_permissions,
        receiver_self_addresses,
        receiver_incept_permissions,
        receiver_incept_addresses
    );

    ps2_ascii ps2_ascii(
        .clk,
        .reset(!reset_b),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .new_code(new_ascii),
        .ascii_code(ascii_input)
        );

    vga_ascii_terminal vga_ascii_terminal(
        .clk,
        .reset(!reset_b),
        .white(pixel_white),
        .h_sync(Hsync),
        .v_sync(Vsync),
        .add_char(sender_send_acks),
        .char_value(global_data[6:0])
    );

  initial begin
    $readmemh("../bin/program.list", programmem);
    $readmemh("../bin/data.list", mainmem);
  end

  wire [(8 + WORD_WIDTH)-1:0] full_read_value;
  wire [WORD_WIDTH/8-1:0][7:0] individual_write_values;
  wire [WORD_WIDTH/8-1:0][7:0] individual_write_masks;

  genvar i;
  generate
    for (i = 0; i < WORD_WIDTH/8 + 1; i = i + 1) begin : FULL_VALUE_LOOP
      assign full_read_value[i*8+7:i*8] = programmem[programmem_addr + i];
    end
    for (i = 0; i < WORD_WIDTH/8; i = i + 1) begin : INDIVIDUAL_OCTET_LOOP
      assign individual_write_values[i] = programmem_write_value[i*8+7:i*8];
      assign individual_write_masks[i] = programmem_write_mask[i*8+7:i*8];
    end
  endgenerate

  always @(posedge clk) begin
    if (!reset_b) begin
        receiver_datas <= 0;
        buffered_ascii <= 1'b0;
    end else begin
        if (new_ascii) begin
            buffered_ascii <= 1'b1;
            character_buffer <= ascii_input;
        end else if (receiver_send_acks) begin
            buffered_ascii <= 1'b0;
        end
    end
  end

  // Handle SRAMs
  always @(posedge clk) begin
    if (programmem_we) begin
      for (int j = 0; j < WORD_WIDTH/8; j++)
        programmem[programmem_write_addr + j] <=
          (individual_write_values[j] & individual_write_masks[j]) |
          (programmem[programmem_write_addr + j] & ~individual_write_masks[j]);
    end
    for (int j = 0; j < WORD_WIDTH/8 + 1; j++)
      programmem_read_value <= full_read_value;
    if (mainmem_we)
      mainmem[mainmem_write_addr] <= mainmem_write_value;
    mainmem_read_value <= mainmem[mainmem_read_addr];
  end
endmodule
