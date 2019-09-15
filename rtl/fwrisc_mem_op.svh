/****************************************************************************
 * fwrisc_mem_op.svh
 *
 * Copyright 2019 Matthew Ballance
 * 
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
 ****************************************************************************/

parameter [3:0]
    OP_LB = 4'd0,				// Load-byte signed
    OP_LH = (OP_LB+4'd1),		// Load-half signed
    OP_LW = (OP_LH+4'd1),		// Load-word
    OP_LBU = (OP_LW+4'd1),		// Load-byte unsigned
    OP_LHU = (OP_LBU+4'd1),		// Load-half unsigned
    OP_SB = (OP_LHU + 4'd1),	// Store-byte
    OP_SH = (OP_SB + 4'd1),		// Store-half
    OP_SW = (OP_SH + 4'd1),		// Store-word
    OP_NUM_MEM = (OP_SW + 4'd1)
;
