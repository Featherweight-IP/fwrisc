
`ifdef FORMAL
	`define assert(x) assert(x)
	`define cover(x) cover(x)
	`define anyseq $anyseq
	`define anyconst $anyconst
`else
	`define assert(x)
	`define cover(x)
	`define anyseq $urandom
	`define anyconst $urandom
`endif