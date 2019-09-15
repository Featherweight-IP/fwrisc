
#include "unit_header.h"

		entry:
			la			x1, pass		// 0x08
			csrw		mtvec, x1		// 0x10
			ecall						// 0x14
			j			done			// 0x18
		pass:
			li			x1, 0			// 0x1C
			li			x2, 25
			csrw		mtvec, x1
			j			done


start_expected:
.word 0x01,  0
.word 0x02,  25
.word 0x2d,  0 			// MTVEC
.word 0x29,  0x80000014 // MEPC
.word 0x2a,  0x0000000b // MCAUSE
end_expected:
