read_libs /home/install/FOUNDRY/digital/90nm/dig/lib/slow.lib
read_hdl protocol.v
elaborate
read_sdc constraint.sdc
set_db syn_generic_effort medium 
set_db syn_map_effort medium
set_db syn_opt_effort medium
syn_generic
syn_map
syn_opt

gui_show
