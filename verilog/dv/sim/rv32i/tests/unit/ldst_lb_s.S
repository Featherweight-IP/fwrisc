
#include "unit_header.h"

		entry:
			la		x1, data
			lb		x2, 0(x1)
			lb		x3, 1(x1)
			li		x1, 0
			j		done
		data:
			.word 0x81828384
			.word 0x05060708


start_expected:
.word 1, 0x00
.word 2, 0xFFFFFF84
.word 3, 0xFFFFFF83
end_expected:
