
`ifdef FORMAL
	`define assert(x) assert(x)
	`define anyseq $anyseq
`else
	`define assert(x)
	`define anyseq $urandom;
`endif