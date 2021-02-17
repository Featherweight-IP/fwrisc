
#include "unit_header.h"

		entry:
			la		x1, data  // 0x08
			lhu		x2, 0(x1) // 0x0C
			lhu		x3, 2(x1) // 0x10
			li		x1, 0     // 0x14
			j		done
		data:
			.word 0x81828384
			.word 0x05060708

start_expected:
.word 1, 0x00
.word 2, 0x00008384
.word 3, 0x00008182
end_expected:
