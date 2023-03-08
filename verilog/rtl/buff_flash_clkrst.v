module buff_flash_clkrst (
	`ifdef USE_POWER_PINS
		inout VPWR,
		inout VGND,
	`endif
	`ifndef CARAVEL_FPGA
	input[11:0] in_n,
	`else
	input[10:0] in_n,
	`endif
	input[2:0] in_s,
	`ifndef CARAVEL_FPGA
	output[11:0] out_s,
	`else
	output[10:0] out_s,
	`endif
	output[2:0] out_n);

`ifdef CARAVEL_FPGA
    	assign out_s = in_n;
	assign out_n = in_s;
`else
	sky130_fd_sc_hd__clkbuf_8 BUF[14:0] (
		`ifdef USE_POWER_PINS
			.VGND(VGND),
			.VNB(VGND),
			.VPB(VPWR),
			.VPWR(VPWR),
		`endif
		.A({in_n, in_s}), 
		.X({out_s, out_n})); 
`endif

endmodule
