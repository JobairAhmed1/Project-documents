
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
#create_clock -name sysclk -period 12 [get_ports {clk}]
set_property PACKAGE_PIN k17 [get_ports {clk}]


# Example: set_property IOSTANDARD LVDS_25 [get_ports [list data_p* data_n*]]
set_property IOSTANDARD LVCMOS33 [get_ports {led1}]
set_property PACKAGE_PIN M14 [get_ports {led1}]

#set_property IOSTANDARD LVCMOS33 [get_ports {led2}]
#set_property PACKAGE_PIN M15 [get_ports {led2}]

#set_property IOSTANDARD LVCMOS33 [get_ports {led3}]
#set_property PACKAGE_PIN G14 [get_ports {led3}]

#set_property IOSTANDARD LVCMOS33 [get_ports {led4}]
#set_property PACKAGE_PIN D18 [get_ports {led4}]

#set_property IOSTANDARD LVCMOS33 [get_ports {led2}]
#set_property PACKAGE_PIN w16 [get_ports {led2}]

#set_property IOSTANDARD LVCMOS33 [get_ports {led3}]
#set_property PACKAGE_PIN J15 [get_ports {led3}]

#set_property IOSTANDARD LVCMOS33 [get_ports {led_btn}]
#set_property PACKAGE_PIN G15 [get_ports {led_btn}]

set_property IOSTANDARD LVCMOS33 [get_ports {current_bit}]
set_property PACKAGE_PIN Y16 [get_ports {current_bit}]  

#set_property IOSTANDARD LVCMOS33 [get_ports {btn2}]
#set_property PACKAGE_PIN K19 [get_ports {btn2}] 

set_property IOSTANDARD LVCMOS33 [get_ports {led_act}]
set_property PACKAGE_PIN g15 [get_ports {led_act}]

set_property IOSTANDARD LVCMOS33 [get_ports {mem_btn}]
set_property PACKAGE_PIN p15 [get_ports {mem_btn}]
#set_property IOSTANDARD LVCMOS33 [get_ports {C}]
#set_property PACKAGE_PIN H15 [get_ports {C}]    


