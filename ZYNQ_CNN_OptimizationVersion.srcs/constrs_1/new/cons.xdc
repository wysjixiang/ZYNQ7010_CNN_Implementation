set_property PACKAGE_PIN U18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN N15 [get_ports reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]

create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

set_property PACKAGE_PIN M14 [get_ports done]
set_property IOSTANDARD LVCMOS33 [get_ports done]
set_property DRIVE 12 [get_ports done]
