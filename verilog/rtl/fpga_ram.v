`default_nettype wire

module RAM128 (CLK,
    EN0,
    VGND,
    VPWR,
    A0,
    Di0,
    Do0,
    WE0);
 input CLK;
 input EN0;
 input VGND;
 input VPWR;
 input [6:0] A0;
 input [31:0] Di0;
 output [31:0] Do0;
 input [3:0] WE0;

reg [31:0] mem[0:127];
reg [6:0] mem_adr0;

always @(posedge CLK) begin
	if (WE0[0])
		mem[A0][7:0] <= Di0[7:0];
	if (WE0[1])
		mem[A0][15:8] <= Di0[15:8];
	if (WE0[2])
		mem[A0][23:16] <= Di0[23:16];
	if (WE0[3])
		mem[A0][31:24] <= Di0[31:24];
	mem_adr0 <= A0;
end
assign Do0 = mem[mem_adr0];

endmodule


module RAM256 (CLK,
    EN0,
    VPWR,
    VGND,
    A0,
    Di0,
    Do0,
    WE0);
 input CLK;
 input EN0;
 input VPWR;
 input VGND;
 input [7:0] A0;
 input [31:0] Di0;
 output [31:0] Do0;
 input [3:0] WE0;

// Port 0 | Read: Sync  | Write: Sync | Mode: Write-First | Write-Granularity: 8 
reg [31:0] mem[0:255];
reg [7:0] mem_adr0;
always @(posedge CLK) begin
	if (WE0[0])
		mem[A0][7:0] <= Di0[7:0];
	if (WE0[1])
		mem[A0][15:8] <= Di0[15:8];
	if (WE0[2])
		mem[A0][23:16] <= Di0[23:16];
	if (WE0[3])
		mem[A0][31:24] <= Di0[31:24];
	mem_adr0 <= A0;
end
assign Do0 = mem[mem_adr0];

endmodule
