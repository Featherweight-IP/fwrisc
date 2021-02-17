
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 6
	slt		x3, x1, x2
	j		done

start_expected:
.word 1, 5
.word 2, 6
.word 3, 1 // 5 < 6
end_expected:


