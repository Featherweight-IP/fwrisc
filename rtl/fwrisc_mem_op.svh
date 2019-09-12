
parameter [3:0]
    OP_LB = 4'd0,				// Load-byte signed
    OP_LH = (OP_LB+4'd1),		// Load-half signed
    OP_LW = (OP_LB+4'd1),		// Load-word
    OP_LBU = (OP_LW+4'd1),		// Load-byte unsigned
    OP_LHU = (OP_LBU+4'd1),		// Load-half unsigned
    OP_SB = (OP_LHU + 4'd1),	// Store-byte
    OP_SH = (OP_SB + 4'd1),		// Store-half
    OP_SW = (OP_SH + 4'd1),		// Store-word
    OP_NUM_MEM = (OP_SW + 4'd1)
;
