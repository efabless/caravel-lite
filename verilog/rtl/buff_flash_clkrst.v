module buff_flash_clkrst (
	`ifdef USE_POWER_PINS
		inout VPWR,
		inout VGND,
	`endif
	input[11:0] in_n, 
	input[2:0] in_s, 
	output[11:0] out_s, 
	output[2:0] out_n);

`ifdef CARAVEL_FPGA
	BUFR #(
		.BUFR_DIVIDE("BYPASS")
	) buf_n2s[11:0] (
		.O(out_s[11:0]),
		.I(in_n[11:0])
	);
	BUFR #(
		.BUFR_DIVIDE("BYPASS")
	) buf_s2n[2:0] (
		.O(out_n[2:0]),
		.I(in_s[2:0])
	);
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