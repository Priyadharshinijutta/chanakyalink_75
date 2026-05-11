#========================================================
# ChanakyaLink SDC Constraint File
# File : protocol.sdc
#========================================================

#-----------------------------
# Clock Constraint
#-----------------------------
# Dummy clock for Cadence synthesis flow

create_clock -name clk -period 10 [get_ports clk]

#-----------------------------
# Input Delay Constraints
#-----------------------------

set_input_delay 2 -clock clk [get_ports slave_id]
set_input_delay 2 -clock clk [get_ports command]
set_input_delay 2 -clock clk [get_ports delay_time]

#-----------------------------
# Output Delay Constraints
#-----------------------------

set_output_delay 2 -clock clk [get_ports checksum]

#-----------------------------
# Clock Uncertainty
#-----------------------------

set_clock_uncertainty 0.5 [get_clocks clk]

#-----------------------------
# Input Transition
#-----------------------------

set_input_transition 0.2 [all_inputs]

#-----------------------------
# Output Load
#-----------------------------

set_load 0.5 [all_outputs]

#-----------------------------
# Driving Cell
#-----------------------------

set_driving_cell -lib_cell INVX1 [all_inputs]

#-----------------------------
# False Path Example
#-----------------------------

set_false_path -from [get_ports slave_id]

#========================================================
# End of Constraints
#========================================================
