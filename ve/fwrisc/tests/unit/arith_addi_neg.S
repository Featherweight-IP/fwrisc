
#include "unit_header.h"

entry:
	li		x1, 5
	add		x3, x1, -1
	j		done

// Expected value for registers
start_expected:
.word 1, 5
.word 3, 4
end_expected:
