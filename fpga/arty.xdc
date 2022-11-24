set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Clock pin
set_property LOC E3 [get_ports {clock}]
set_property IOSTANDARD LVCMOS33 [get_ports {clock}]

# reset
set_property LOC C2 [get_ports {resetb}]
set_property IOSTANDARD LVCMOS33 [get_ports {resetb}]

# gpio - IO1
set_property LOC T10 [get_ports {gpio}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio}]

# flash
set_property LOC L13 [get_ports {flash_csb}]
set_property IOSTANDARD LVCMOS33 [get_ports {flash_csb}]
set_property LOC L16 [get_ports {flash_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {flash_clk}]
set_property LOC K17 [get_ports {flash_io0}]
set_property IOSTANDARD LVCMOS33 [get_ports {flash_io0}]
set_property LOC K18 [get_ports {flash_io1}]
set_property IOSTANDARD LVCMOS33 [get_ports {flash_io1}]

# inout [37:0] user project io
# bank 0
# JTAG       = mprj_io[0]		(inout)
# IO0
set_property LOC V15 [get_ports {mprj_io[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[0]}]

## housekeeping SPI - connected to Arduino-style SPI/ICSP connector
# SDO 	  = mprj_io[1]		(output)
set_property LOC G1 [get_ports {mprj_io[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[1]}]

# SDI 	  = mprj_io[2]		(input)
set_property LOC H1 [get_ports {mprj_io[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[2]}]

# CSB 	  = mprj_io[3]		(input)
set_property LOC C1 [get_ports {mprj_io[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[3]}]

# SCK	  = mprj_io[4]		(input)
set_property LOC F1 [get_ports {mprj_io[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[4]}]
##

# serial - connected to FTDI
# ser_rx     = mprj_io[5]		(input)
set_property LOC A9 [get_ports {mprj_io[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[5]}]

# ser_tx     = mprj_io[6]		(output)
set_property LOC D10 [get_ports {mprj_io[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[6]}]
##

## irq 	  = mprj_io[7]		(input)
# IO2
set_property LOC P14 [get_ports {mprj_io[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[7]}]
##

## user spi flash - PMOD A
# user_flash_csb = mprj_io[8]
set_property LOC G13 [get_ports {mprj_io[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[8]}]

# user_flash_sck = mprj_io[9]
set_property LOC D12 [get_ports {mprj_io[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[9]}]

# user_flash_io0 = mprj_io[10]
set_property LOC B11 [get_ports {mprj_io[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[10]}]

# user_flash_io1 = mprj_io[11]
set_property LOC A11 [get_ports {mprj_io[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[11]}]
##

## IO3-9
set_property LOC T11 [get_ports {mprj_io[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[12]}]

set_property LOC R12 [get_ports {mprj_io[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[13]}]

set_property LOC T14 [get_ports {mprj_io[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[14]}]

set_property LOC T15 [get_ports {mprj_io[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[15]}]

set_property LOC T16 [get_ports {mprj_io[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[16]}]

set_property LOC N15 [get_ports {mprj_io[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[17]}]

set_property LOC M16 [get_ports {mprj_io[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[18]}]
##

# bank 1
## IO38-26
set_property LOC T18 [get_ports {mprj_io[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[19]}]

set_property LOC U17 [get_ports {mprj_io[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[20]}]

set_property LOC N14 [get_ports {mprj_io[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[21]}]

set_property LOC N16 [get_ports {mprj_io[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[22]}]

set_property LOC R16 [get_ports {mprj_io[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[23]}]

set_property LOC P15 [get_ports {mprj_io[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[24]}]

set_property LOC R15 [get_ports {mprj_io[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[25]}]

set_property LOC R13 [get_ports {mprj_io[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[26]}]

set_property LOC R11 [get_ports {mprj_io[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[27]}]

set_property LOC R10 [get_ports {mprj_io[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[28]}]

set_property LOC M13 [get_ports {mprj_io[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[29]}]

set_property LOC V16 [get_ports {mprj_io[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[30]}]

set_property LOC U11 [get_ports {mprj_io[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[31]}]
##

## SPI controller - connected to Arduino shield SPI pins (IO10-13)
# spi_sck    = mprj_io[32]		(output)
set_property LOC P17 [get_ports {mprj_io[32]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[32]}]

# spi_csb    = mprj_io[33]		(output)
set_property LOC V17 [get_ports {mprj_io[33]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[33]}]

# spi_sdi    = mprj_io[34]		(input)
set_property LOC R17 [get_ports {mprj_io[34]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[34]}]

# spi_sdo    = mprj_io[35]		(output)
set_property LOC U18 [get_ports {mprj_io[35]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[35]}]
##

##
# flash_io2  = mprj_io[36]		(inout) 
set_property LOC L14 [get_ports {mprj_io[36]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[36]}]

# flash_io3  = mprj_io[37]		(inout) 
set_property LOC M14 [get_ports {mprj_io[37]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mprj_io[37]}]
##

create_clock -name clock -period 10.0 [get_ports clock]

set_property INTERNAL_VREF 0.675 [get_iobanks 34]
