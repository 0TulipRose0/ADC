## Clock signal
#set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clkin }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -name sys_clk_pin -period 4.00 -waveform {0 2} [get_ports {clkin}];

## ADC delay  
set_input_delay -clock encode -max 7.9 [get_ports da]
set_input_delay -clock encode -min 2.7 [get_ports da]

set_input_delay -clock encode -max 7.9 [get_ports  db]
set_input_delay -clock encode -min 2.7 [get_ports  db]

set_multicycle_path 2 -setup -start -from [get_clocks encode] -to [get_clocks da]
set_multicycle_path 1 -hold -from [get_clocks encode] -to [get_clocks da]

set_multicycle_path 2 -setup -start -from [get_clocks encode] -to [get_clocks db]
set_multicycle_path 1 -hold -from [get_clocks encode] -to [get_clocks db]