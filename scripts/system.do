onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/nRST
add wave -noupdate -group datapath0 /system_tb/DUT/CPU/DP0/CU/instr
add wave -noupdate -group datapath0 /system_tb/DUT/CPU/DP0/PR/prif/instr_in_1
add wave -noupdate -group datapath0 /system_tb/DUT/CPU/DP0/RF/register
add wave -noupdate -group datapath0 /system_tb/DUT/CPU/DP0/pc
add wave -noupdate -group datapath0 /system_tb/DUT/CPU/DP0/next_pc
add wave -noupdate -group datapath0 /system_tb/DUT/CPU/DP0/reg_enable
add wave -noupdate -group datapath1 /system_tb/DUT/CPU/DP1/CU/instr
add wave -noupdate -group datapath1 /system_tb/DUT/CPU/DP1/RF/register
add wave -noupdate -group datapath1 /system_tb/DUT/CPU/DP1/PR/prif/instr_in_1
add wave -noupdate -group datapath1 /system_tb/DUT/CPU/DP1/pc
add wave -noupdate -group datapath1 /system_tb/DUT/CPU/DP1/next_pc
add wave -noupdate -group datapath1 /system_tb/DUT/CPU/DP0/reg_enable
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/iwait
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/dwait
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/iload
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/dload
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/dstore
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate -group cache-control /system_tb/DUT/CPU/ccif/daddr
add wave -noupdate -group multicores /system_tb/DUT/CPU/ccif/ccwait
add wave -noupdate -group multicores /system_tb/DUT/CPU/ccif/ccinv
add wave -noupdate -group multicores /system_tb/DUT/CPU/ccif/ccwrite
add wave -noupdate -group multicores /system_tb/DUT/CPU/ccif/cctrans
add wave -noupdate -group multicores /system_tb/DUT/CPU/ccif/ccsnoopaddr
add wave -noupdate -group {mem ctrl} /system_tb/DUT/CPU/CC/curr_selected
add wave -noupdate -group {mem ctrl} /system_tb/DUT/CPU/CC/next_selected
add wave -noupdate -group {mem ctrl} /system_tb/DUT/CPU/CC/other
add wave -noupdate -group {mem ctrl} /system_tb/DUT/CPU/CC/curr_state
add wave -noupdate -group {mem ctrl} /system_tb/DUT/CPU/CC/next_state
add wave -noupdate -expand -group coherency /system_tb/DUT/CPU/CC/COH/next_state
add wave -noupdate -expand -group coherency /system_tb/DUT/CPU/CC/COH/curr_state
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/dcif0/ihit
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/dcif0/imemREN
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/dcif0/imemload
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/dcif0/imemaddr
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/CM0/ICACHE/iREN
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/CM0/ICACHE/iwait
add wave -noupdate -expand -group cache0 -group icache /system_tb/DUT/CPU/CM0/ICACHE/iload
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/dhit
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/dmemREN
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/dmemWEN
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/dmemload
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/dmemstore
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/dmemaddr
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/dcif0/flushed
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/curr_cache0
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/next_cache0
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/curr_cache1
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/next_cache1
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_tag
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_idx
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_cache
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_blk
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_dirty0
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_dirty1
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_cache0_data
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp_cache1_data
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp1_daddr0
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp1_daddr1
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp2_daddr0
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp2_daddr1
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/ccsnoopaddr
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/sp2_ccsnoopaddr
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/ccwait
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/ccinv
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/ccwrite
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/cctrans
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/dwait
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/dREN
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/dWEN
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/dload
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/dstore
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/daddr
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/curr_state
add wave -noupdate -expand -group cache0 -expand -group dcache /system_tb/DUT/CPU/CM0/DCACHE/next_state
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/dcif/ihit
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/dcif/imemREN
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/dcif/imemload
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/dcif/imemaddr
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/iREN
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/iwait
add wave -noupdate -expand -group cache1 -group icache /system_tb/DUT/CPU/CM1/ICACHE/iload
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/dhit
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/dmemREN
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/dmemWEN
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/dmemload
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/dmemstore
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/dmemaddr
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dcif/flushed
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/curr_cache0
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/next_cache0
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/curr_cache1
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/next_cache1
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_tag
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_idx
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_cache
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_blk
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_dirty0
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_dirty1
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_cache0_data
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp_cache1_data
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp1_daddr0
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp1_daddr1
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp2_daddr0
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp2_daddr1
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/ccsnoopaddr
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/sp2_ccsnoopaddr
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/ccwait
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/ccinv
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/ccwrite
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/cctrans
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dwait
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dREN
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dWEN
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dload
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/dstore
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/daddr
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/curr_state
add wave -noupdate -expand -group cache1 -expand -group dcache /system_tb/DUT/CPU/CM1/DCACHE/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19038 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 140
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {178227 ps}
