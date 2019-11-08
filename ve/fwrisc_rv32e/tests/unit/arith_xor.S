
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 6
	xor		x3, x1, x2
	j		done


start_expected:
.word 1, 5
.word 2, 6
.word 3, 3
end_expected:



