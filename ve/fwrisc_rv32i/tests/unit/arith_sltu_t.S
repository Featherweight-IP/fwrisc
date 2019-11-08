
#include "unit_header.h"

entry:
	li		x1, 0x80000000
	li		x2, 0x80000001
	sltu	x3, x1, x2
	j		done


start_expected:
.word 1, 0x80000000
.word 2, 0x80000001
.word 3, 1
end_expected:



