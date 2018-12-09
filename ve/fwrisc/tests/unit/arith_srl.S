
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 0x80000000
	srl		x3, x2, x1
	j		done


start_expected:
.word 1, 5
.word 2, 0x80000000
.word 3, (0x80000000 >> 5)
end_expected:


