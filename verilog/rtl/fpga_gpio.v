`default_nettype none

module fpga_gpio (
    inout wire pad_io,
    input wire chip_o,
    output wire chip_i,
    input wire chip_oe_n,
    input wire chip_ie_n
);

    assign chip_i = (chip_ie_n ? 'bz : pad_io);
    assign pad_io = (chip_oe_n ? 'bz : chip_o);

endmodule
