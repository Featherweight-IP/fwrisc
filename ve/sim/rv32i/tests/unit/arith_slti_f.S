
#include "unit_header.h"

entry:
	li		x1, 5
	slti	x3, x1, 4
	j		done


start_expected:
.word 1, 5
.word 3, 0 // !(5<4)
end_expected:



