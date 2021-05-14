
/****************************************************************************
 * fwrisc_atomic_op.svh
 *
 * Copyright 2018-2019 Matthew Ballance
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
    OP_AMO_NOP  = 4'b0000,
    OP_AMO_SWAP = 4'b0001,
    OP_AMO_ADD  = 4'b0010,
    OP_AMO_AND  = 4'b0011,
    OP_AMO_OR   = 4'b0100,
    OP_AMO_XOR  = 4'b0101,
    OP_AMO_MAXS = 4'b0110,
    OP_AMO_MAXU = 4'b0111,
    OP_AMO_MINS = 4'b1000,
    OP_AMO_MINU = 4'b1001,
    OP_AMO_LR   = 4'b1010,
    OP_AMO_SC   = 4'b1011
    ;
    
    