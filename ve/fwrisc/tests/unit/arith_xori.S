
#include "unit_header.h"

entry:
	li		x1, 5
	xori	x3, x1, 6
	j		done


start_expected:
.word 1, 5
.word 3, 3
end_expected:


