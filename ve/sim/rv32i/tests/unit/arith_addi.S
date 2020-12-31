
#include "unit_header.h"

entry:
	li		x1, 5
	add		x3, x1, 6
	j		done

// Expected value for registers
start_expected:
.word 1, 5
.word 3, 11
end_expected:
