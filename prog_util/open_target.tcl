if {$argc != 1} {exit 1}

set fname [lindex $argv 0]
puts $fname
open_hw
connect_hw_server -url localhost:3121
open_hw_target $env(JTAG)

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE ${fname} [lindex [get_hw_devices] 0]
puts [get_property PROGRAM.FILE [lindex [get_hw_devices] 0]]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
