
#include "unit_header.h"

entry:
	li		x2, 0x80000000
	srli	x3, x2, 5
	j		done


start_expected:
.word 2, 0x80000000
.word 3, (0x80000000 >> 5)
end_expected:



