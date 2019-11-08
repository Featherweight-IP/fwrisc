
#include "unit_header.h"

		entry:
			la		x1, data
			li		x2, 0xeeff
			sh		x2, 0(x1)
			li		x2, 0x55aa
			sh		x2, 2(x1)
			lw		x3, 0(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708

start_expected:
.word 1, 0x00000000
.word 2, 0x000055aa
.word 3, 0x55aaeeff
end_expected:
