
#include "unit_header.h"

		entry:
			la		x1, data
			lw		x2, 0(x1)
			lw		x3, 4(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708

start_expected:
.word 1, 0x00
.word 2, 0x01020304
.word 3, 0x05060708
end_expected:
