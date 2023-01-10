#!/usr/bin/tclsh

set scriptDir [file normalize [file dirname [info script]]]
set projectRoot [file normalize [file join $scriptDir ..]]

# configuration

set projectName "caravel-arty"
set designPart "xc7a35ticsg324-1L"
set projectDir [file join $projectRoot "build/vivado"]
set reportName [file join $projectDir "${projectName}_utilization.txt"]
set bitstreamPath [file join $projectDir ${projectName}.bit]

if { [info exists env(MCW_ROOT) ] } {
    set mgmtDir $::env(MCW_ROOT)
} else {
    set mgmtDir [file join $projectRoot "mgmt_core_wrapper"]
}

# main script

create_project -f $projectName $projectDir -part $designPart
add_files -norecurse "./verilog/rtl/defines.v" \
    "./verilog/rtl/user_defines.v" \
    "./verilog/rtl/pads.v" \
    "${mgmtDir}/verilog/rtl/mgmt_core.v" \
    "${mgmtDir}/verilog/rtl/mgmt_core_wrapper.v" \
    "${mgmtDir}/verilog/rtl/VexRiscv_MinDebug.v" \
    "./verilog/rtl/fpga_ram.v" \
    "./verilog/rtl/fpga_gpio.v" \
    "./verilog/rtl/clock_div.v" \
    "./verilog/rtl/caravel_clocking.v" \
    "./verilog/rtl/housekeeping.v" \
    "./verilog/rtl/housekeeping_spi.v" \
    "./verilog/rtl/gpio_logic_high.v" \
    "./verilog/rtl/gpio_control_block.v" \
    "./verilog/rtl/gpio_defaults_block.v" \
    "./verilog/rtl/mgmt_protect_hv.v" \
    "./verilog/rtl/mprj_logic_high.v" \
    "./verilog/rtl/mprj2_logic_high.v" \
    "./verilog/rtl/mprj_io.v" \
    "./verilog/rtl/mgmt_protect.v" \
    "./verilog/rtl/user_id_programming.v" \
    "./verilog/rtl/spare_logic_block.v" \
    "./verilog/rtl/constant_block.v" \
    "./verilog/rtl/chip_io.v" \
    "./verilog/rtl/gpio_signal_buffering.v" \
    "./verilog/rtl/debug_regs.v" \
    "./verilog/rtl/buff_flash_clkrst.v" \
    "./verilog/rtl/__user_project_wrapper.v" \
    "./verilog/rtl/caravel.v"
    #"./verilog/rtl/simple_por.v"
    #"./verilog/rtl/xres_buf.v" 
import_files -force -norecurse
set_property is_global_include 1 [get_files "defines.v"]
set_property is_global_include 1 [get_files "user_defines.v"]
set_property is_global_include 1 [get_files "pads.v"]
set_property top caravel [current_fileset]
read_xdc "./fpga/arty.xdc"
update_compile_order -fileset sources_1

# Synthesis
synth_design -directive default -top caravel -part $designPart -verilog_define CARAVEL_FPGA

# Synthesis report
report_timing_summary -file [file join $projectDir ${projectName}_timing_synth.rpt]
report_utilization -hierarchical -file [file join $projectDir ${projectName}_utilization_hierarchical_synth.rpt]
report_utilization -file [file join $projectDir ${projectName}_utilization_synth.rpt]

# Optimize design
opt_design -directive default

# Placement
place_design -directive default

# Placement report
report_utilization -hierarchical -file [file join $projectDir ${projectName}_utilization_place.rpt]
report_utilization -file [file join $projectDir ${projectName}_utilization_hierarchical_place.rpt]
report_io -file [file join $projectDir ${projectName}_utilization_hierarchical_io.rpt]
report_control_sets -verbose -file [file join $projectDir ${projectName}_control_sets.rpt]
report_clock_utilization -file [file join $projectDir ${projectName}_clock_utilization.rpt]

# Routing
route_design -directive default
phys_opt_design -directive default
write_checkpoint -force [file join $projectDir ${projectName}_route.dcp]

# Routing report
report_timing_summary -no_header -no_detailed_paths
report_route_status -file [file join $projectDir ${projectName}_route_status.rpt]
report_drc -file [file join $projectDir ${projectName}_drc.rpt]
report_timing_summary -datasheet -max_paths 10 -file [file join $projectDir ${projectName}_timing.rpt]
report_power -file [file join $projectDir ${projectName}_power.rpt]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Bitstream generation
write_bitstream -force ${bitstreamPath}
write_cfgmem -force -format bin -interface spix4 -size 16 -loadbit "up 0x0 ${bitstreamPath}" -file [file join $projectDir ${projectName}.bin]

# End
quit
