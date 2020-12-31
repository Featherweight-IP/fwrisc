
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 6
	sub		x3, x2, x1
	j		done


start_expected:
.word 1, 5
.word 2, 6
.word 3, 1
end_expected:


