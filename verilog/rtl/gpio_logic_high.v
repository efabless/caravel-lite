module gpio_logic_high(
 `ifdef USE_POWER_PINS
         inout vccd1,
         inout vssd1,
  `endif

   output wire gpio_logic1
);
`ifndef CARAVEL_FPGA
 sky130_fd_sc_hd__conb_1 gpio_logic_high (
`ifdef USE_POWER_PINS
            .VPWR(vccd1),
            .VGND(vssd1),
            .VPB(vccd1),
            .VNB(vssd1),
`endif
            .HI(gpio_logic1),
            .LO()
    );
`else
    assign gpio_logic1 = 1'b1;
`endif
endmodule
