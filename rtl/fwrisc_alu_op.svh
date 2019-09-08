
parameter [3:0] 
OP_ADD = 4'd0,			// 0
OP_SUB = (OP_ADD+4'd1),	// 1
OP_AND = (OP_SUB+4'd1), // 2
OP_OR  = (OP_AND+4'd1), // 3
/**
 * OP_CLR (4)
 * Uses OP_A as a mask, where each set bit
 * clears the corresponding bit in OP_B
 */
OP_CLR = (OP_OR+4'd1),	// 4
OP_EQ  = (OP_CLR+4'd1),	// 5
OP_LT  = (OP_EQ+4'd1),	// 6
OP_LTU = (OP_LT+4'd1),	// 7
OP_OPA = (OP_LTU+4'd1), // 8
OP_OPB = (OP_OPA+4'd1), // 9
OP_XOR = (OP_OPB+4'd1); // 10