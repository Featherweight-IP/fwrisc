/****************************************************************************
 * fwrisc_mul_div_shift_op.svh
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
OP_SLL     = 4'd0,
OP_SRL     = (OP_SLL + 4'd1),
OP_SRA     = (OP_SRL + 4'd1),
OP_MUL     = (OP_SRA + 4'd1),
OP_MULH    = (OP_MUL + 4'd1),
OP_MULS    = (OP_MULH + 4'd1),
OP_MULSH   = (OP_MULS + 4'd1),
OP_DIV     = (OP_MULSH + 4'd1),
OP_REM     = (OP_DIV + 4'd1),
OP_NUM_MDS = (OP_REM + 4'd1)
;
