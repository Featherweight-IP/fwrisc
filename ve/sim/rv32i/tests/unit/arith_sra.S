
#include "unit_header.h"

entry:
	li		x1, 4
	li		x2, 0x80000000
	sra		x3, x2, x1
	j		done


start_expected:
.word 1, 4
.word 2, 0x80000000
.word 3, 0xF8000000
end_expected:

