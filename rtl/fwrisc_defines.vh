/****************************************************************************
 * Copyright 2018 Matthew Ballance
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

`define	OP_ADD  4'b0000
`define	OP_SUB  4'b0001
`define	OP_AND  4'b0010
`define	OP_OR   4'b0011
`define	OP_CLR  4'b0100
`define	OP_XOR  4'b0101
//`define	OP_SLL  4'b0101
//`define OP_SRL  4'b0110
//`define	OP_SRA  4'b0111
//`define	OP_MUL  4'b1000
//`define	OP_MULH 4'b1001
//`define	OP_DIV  4'b1010
//`define	OP_REM  4'b1011

`define MDS_OP_SLL `4b0000
`define MDS_OP_SRL `4b0001
`define MDS_OP_SRA `4b0010

`define	COMPARE_EQ  2'b00
`define	COMPARE_LT  2'b01
`define	COMPARE_LTU 2'b10

`define FETCH					4'b0000
`define DECODE					4'b0001
`define EXECUTE					4'b0010
`define CSR_1					4'b0011
`define CSR_2					4'b0100
`define MEMW					4'b0101
`define MEMR					4'b0110
`define EXCEPTION_1				4'b0111
`define EXCEPTION_2				4'b1000
`define MDS_WAIT				4'b1001
//`define SHIFT_1					4'b1001
//`define SHIFT_2					4'b1010
`define CYCLE_COUNT_UPDATE_1	4'b1011
`define CYCLE_COUNT_UPDATE_2	4'b1100
`define INSTR_COUNT_UPDATE_1	4'b1101
