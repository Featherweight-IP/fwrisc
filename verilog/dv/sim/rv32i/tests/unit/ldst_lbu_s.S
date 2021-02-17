
#include "unit_header.h"

		entry:
			la		x1, data  // 0x08
			lbu		x2, 0(x1) // 0x0C
			lbu		x3, 1(x1) // 0x10
			li		x1, 0     // 0x14
			j		done
		data:
			.word 0x81828384
			.word 0x05060708

start_expected:
.word 1, 0x00
.word 2, 0x00000084
.word 3, 0x00000083
end_expected:
