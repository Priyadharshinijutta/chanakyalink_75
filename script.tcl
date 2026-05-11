#===========================================================
# FILE : genus_script.tcl
# CHANAKYALINK SYNTHESIS SCRIPT
#===========================================================

set_db init_lib_search_path ./lib
set_db init_hdl_search_path ./design

#-----------------------------------------------------------
# STANDARD CELL LIBRARY
#-----------------------------------------------------------

read_libs typical.lib

#-----------------------------------------------------------
# READ DESIGN FILES
#-----------------------------------------------------------

read_hdl uart_tx.v
read_hdl uart_rx.v
read_hdl ai_decision_module.v
read_hdl chanakyalink_master.v
read_hdl chanakyalink_slave.v

#-----------------------------------------------------------
# ELABORATE TOP MODULE
#-----------------------------------------------------------

elaborate chanakyalink_master

#-----------------------------------------------------------
# CHECK DESIGN
#-----------------------------------------------------------

check_design

#-----------------------------------------------------------
# READ CONSTRAINTS
#-----------------------------------------------------------

read_sdc constraints.sdc

#-----------------------------------------------------------
# SYNTHESIS
#-----------------------------------------------------------

syn_generic
syn_map
syn_opt

#-----------------------------------------------------------
# REPORTS
#-----------------------------------------------------------

report_area  > reports/area_report.rpt
report_power > reports/power_report.rpt
report_timing > reports/timing_report.rpt

#-----------------------------------------------------------
# OUTPUT NETLIST
#-----------------------------------------------------------

write_hdl > output/chanakyalink_master_netlist.v

#-----------------------------------------------------------
# EXIT
#-----------------------------------------------------------

exit
