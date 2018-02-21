set jtag [lindex $argv 0]
puts $jtag
set val [lindex $argv 1]
puts $val
set ILA_FILE [lindex $argv 2]
puts $ILA_FILE
open_hw
connect_hw_server -url localhost:3121
open_hw_target $jtag
current_hw_device [get_hw_devices xcvu095_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu095_0] 0]
set_property PROBES.FILE $ILA_FILE [get_hw_devices xcvu095_0]
refresh_hw_device [lindex [get_hw_devices xcvu095_0] 0]
set_property OUTPUT_VALUE $val [get_hw_probes static_region_i/vio_0_probe_out1 -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu095_0] -filter {CELL_NAME=~"static_region_i/vio_0"}]]
commit_hw_vio [get_hw_probes {static_region_i/vio_0_probe_out1} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu095_0] -filter {CELL_NAME=~"static_region_i/vio_0"}]]
