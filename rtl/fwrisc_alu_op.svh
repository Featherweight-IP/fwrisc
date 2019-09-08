
parameter [3:0] 
OP_ADD = 4'd0,			// 0
OP_SUB = (OP_ADD+4'd1),	// 1
OP_AND = (OP_SUB+4'd1), // 2
OP_OR  = (OP_AND+4'd1), // 3
OP_CLR = (OP_OR+4'd1),	// 4
OP_EQ  = (OP_CLR+4'd1),	// 5
OP_LT  = (OP_EQ+4'd1),	// 6
OP_LTU = (OP_LT+4'd1),	// 7
OP_NOP = (OP_LTU+4'd1),
OP_XOR = (OP_NOP+4'd1);