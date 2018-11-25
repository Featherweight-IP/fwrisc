# Written by Synplify Pro version mapact, Build 2172R. Synopsys Run ID: sid1542848263 
# Top Level Design Parameters 

# Clocks 
create_clock -period 10.000 -name {clock} [get_ports {clock}] 
create_generated_clock -name {clock_4} -source [get_ports clock] -divide_by 4 [get_ports {clock_o}]

# Virtual Clocks 

# Generated Clocks 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 

# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

