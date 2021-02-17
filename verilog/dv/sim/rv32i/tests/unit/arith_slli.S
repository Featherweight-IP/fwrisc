
#include "unit_header.h"

entry:
	li		x1, 1
	slli	x3, x1, 5
	j		done

start_expected:
.word 1, 1
.word 3, (1 << 5)
end_expected:

