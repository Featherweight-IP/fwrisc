
#include "unit_header.h"

		entry:
			la		x8, _trap_handler
			csrw	mtvec, x8
			la		x9, data
			lw		x7, 2(x9)

			li		x8, 4		// When we come back, clear out x8
			j		done
		1:
			li		x8, 26
			j		done
			nop
		_trap_handler:
			csrr	x8, mepc // Increment beyond the faulting instruction
			addi	x8, x8, 4
			csrw	mepc, x8
			mret
		data:
			.word	0x01020304
			.word	0x05060708

start_expected:
.word 8, 4
.word 9,  0x80000044
.word 37, 0x80000034 // MTVEC
.word 41, 0x80000020 // MEPC
.word 42, 0x00000004 // MCAUSE
.word 43, 0x80000046 // MTVAL
end_expected:
