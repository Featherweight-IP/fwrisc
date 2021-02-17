
#include "unit_header.h"

entry:
	li		x1, 5
	li		x2, 6
//	c.add 	x3, x1, x2
	c.add 	x1, x2
	j		done


start_expected:
.word 1, 11
.word 2, 6
end_expected:


