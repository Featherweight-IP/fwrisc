
#include "unit_header.h"

		entry:
			la		x8, _trap_handler
			csrw	mtvec, x8
			bne		x8, zero, 1f+2	// Jump will not be taken, since the address is misaligned

			li		x8, 4				// When we come back, clear out x8
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
.word 37, 0x8000002c // MTVEC
.word 41, 0x80000018 // MEPC
.word 42, 0x00000000 // MCAUSE
.word 43, 0x80000022 // MTVAL
end_expected:
