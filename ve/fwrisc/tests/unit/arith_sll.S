
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 1
	sll		x3, x2, x1
	j		done

start_expected:
.word 1, 5
.word 2, 1
.word 3, (1 << 5)
end_expected:


