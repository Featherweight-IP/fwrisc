
#include "unit_header.h"

		entry:
			la		x1, data
			lh		x2, 0(x1)
			lh		x3, 2(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708

start_expected:
.word 1, 0x00
.word 2, 0x0304
.word 3, 0x0102
end_expected:
