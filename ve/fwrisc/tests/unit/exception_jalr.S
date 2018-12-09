
#include "unit_header.h"

		entry:
			la		x8, _trap_handler
			csrw	mtvec, x8
			la		x9, 1f
			jalr	2(x9)		// Jump will not be taken, since the address is misaligned

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

start_expected:
.word 8, 4
.word 37, 0x80000028 // MTVEC
.word 41, 0x80000034 // MEPC
.word 42, 0x00000020 // MCAUSE
.word 43, 0x8000002a // MTVAL
end_expected:
