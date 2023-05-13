set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
set_property PACKAGE_PIN Y9 [get_ports {clk}]
create_clock -period 10 [get_ports clk]

set_property PACKAGE_PIN Y21 [get_ports {blue[0]}]; # "VGA-B0"
set_property PACKAGE_PIN Y20 [get_ports {blue[1]}]; # "VGA-B1"
set_property PACKAGE_PIN AB20 [get_ports {blue[2]}]; # "VGA-B2"
set_property PACKAGE_PIN AB19 [get_ports {blue[3]}]; # "VGA-B3"
set_property PACKAGE_PIN AB22 [get_ports {green[0]}]; # "VGA-G0"
set_property PACKAGE_PIN AA22 [get_ports {green[1]}]; # "VGA-G1"
set_property PACKAGE_PIN AB21 [get_ports {green[2]}]; # "VGA-G2"
set_property PACKAGE_PIN AA21 [get_ports {green[3]}]; # "VGA-G3"
set_property PACKAGE_PIN V20 [get_ports {red[0]}]; # "VGA-R0"
set_property PACKAGE_PIN U20 [get_ports {red[1]}]; # "VGA-R1"
set_property PACKAGE_PIN V19 [get_ports {red[2]}]; # "VGA-R2"
set_property PACKAGE_PIN V18 [get_ports {red[3]}]; # "VGA-R3"
set_property PACKAGE_PIN AA19 [get_ports {hsync}]; # "VGA-HS"
set_property PACKAGE_PIN Y19 [get_ports {vsync}]; # "VGA-VS"
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

set_property PACKAGE_PIN T18 [get_ports moveU];
set_property PACKAGE_PIN R16 [get_ports moveD];
set_property PACKAGE_PIN N15 [get_ports moveL];
set_property PACKAGE_PIN R18 [get_ports moveR];
set_property PACKAGE_PIN H17 [get_ports US_U];
set_property PACKAGE_PIN H18 [get_ports US_D];
set_property PACKAGE_PIN H19 [get_ports US_L];
set_property PACKAGE_PIN F21 [get_ports US_R];
set_property PACKAGE_PIN P16 [get_ports shoot];
set_property PACKAGE_PIN F22 [get_ports display_enemy];
set_property PACKAGE_PIN M15 [get_ports reset_game];
set_property IOSTANDARD LVCMOS33 [get_ports moveU];                                             
set_property IOSTANDARD LVCMOS33 [get_ports moveD];
set_property IOSTANDARD LVCMOS33 [get_ports moveL];
set_property IOSTANDARD LVCMOS33 [get_ports moveR];
set_property IOSTANDARD LVCMOS33 [get_ports US_U];
set_property IOSTANDARD LVCMOS33 [get_ports US_D];
set_property IOSTANDARD LVCMOS33 [get_ports US_L];
set_property IOSTANDARD LVCMOS33 [get_ports US_R];
set_property IOSTANDARD LVCMOS33 [get_ports shoot];
set_property IOSTANDARD LVCMOS33 [get_ports display_enemy];
set_property IOSTANDARD LVCMOS33 [get_ports reset_game];
