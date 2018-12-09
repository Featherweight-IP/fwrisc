
#include "unit_header.h"

		entry:
			la		x2, 1f // la is a two-word instruction (0x08, 0x0C)
			addi	x2, x2, -4 // We'll add in the offset now
			jalr	x1, 4(x2) // 0x14: R[1] <= 0x18
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry // 0x1c
			sub		x4, x1, x3
			li		x1, 0
			li		x2, 0
			li		x3, 0
			j		done


start_expected:
.word 1, 0
.word 2, 0
.word 3, 0
.word 4, 0x10
end_expected:
