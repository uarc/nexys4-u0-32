# vga-controller
A VGA controller written in Verilog; can be parameterized to use CVT and any resolution desired

By default the module is in 640x480 @ 60Hz with a pixel clock of 25.125MHz.

The `will_display` output indicates that a pixel should be fetched and displayed on the following cycle.

Example of how to use the module:

```
vga
    #(  .TIME_HORIZONTAL_FRONT_PORCH(88),
        .TIME_HORIZONTAL_SYNC_PULSE(44),
        .TIME_HORIZONTAL_BACK_PORCH(148),
        .TIME_HORIZONTAL_VIDEO(1920),

        .TIME_VERTICAL_FRONT_PORCH(4),
        .TIME_VERTICAL_SYNC_PULSE(5),
        .TIME_VERTICAL_BACK_PORCH(36),
        .TIME_VERTICAL_VIDEO(1080),
        .HORIZONTAL_COUNTER_WIDTH(12),

        .VERTICAL_COUNTER_WIDTH(12),
        .HORIZONTAL_SYNC_POLARITY(1'b1))
    vga(...);
```
