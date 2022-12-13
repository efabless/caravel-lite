`default_nettype wire

module fpga_gpio (
    inout io,
    input o,
    output i,
    input oe,
    input ie
);

    assign io = oe ? o : 'bz;
    assign i = ie ? io : 'b0;

endmodule