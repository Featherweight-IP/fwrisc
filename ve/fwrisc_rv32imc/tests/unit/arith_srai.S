
#include "unit_header.h"

entry:
	li		x2, 0x80000000
	srai	x3, x2, 4
	j		done


start_expected:
.word 2, 0x80000000
.word 3, 0xF8000000
end_expected:

