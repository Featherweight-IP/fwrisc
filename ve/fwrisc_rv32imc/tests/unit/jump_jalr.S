
#include "unit_header.h"

		entry:
			la		x2, 1f // la is a two-word instruction (0x08, 0x0C)
			jalr	x1, x2 // 0x10: R[1] <= 0x14
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry  // 0x1c
			sub		x4, x1, x3 //0x24
			li		x1, 0
			li		x2, 0
			li		x3, 0
			j		done


start_expected:
.word 1, 0
.word 2, 0
.word 3, 0
.word 4, 12
end_expected:
