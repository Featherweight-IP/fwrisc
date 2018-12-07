
#include "unit_header.h"

entry:
	li		x1, 0x80000000
	li		x2, 0x80000001
	sltu	x3, x1, x2
	j		done





