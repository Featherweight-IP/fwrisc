
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 5
	slt		x3, x1, x2
	j		done


start_expected:
.word 1, 5
.word 2, 5
.word 3, 0 // !(5<5)
end_expected:


