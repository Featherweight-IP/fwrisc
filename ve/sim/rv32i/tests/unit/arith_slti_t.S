
#include "unit_header.h"


entry:
	li		x1, 5
	slti	x3, x1, 6
	j		done


start_expected:
.word 1, 5
.word 3, 1 // (5<6)
end_expected:


