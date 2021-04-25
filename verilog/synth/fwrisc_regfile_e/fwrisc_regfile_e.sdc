
create_clock -period 10 [get_ports clock]
derive_pll_clocks

set_input_delay -clock clock -max 3 [all_inputs]
set_input_delay -clock clock -min 2 [all_inputs]

set_output_delay -clock clock -max 3 [all_outputs]
set_output_delay -clock clock -min 2 [all_outputs]

