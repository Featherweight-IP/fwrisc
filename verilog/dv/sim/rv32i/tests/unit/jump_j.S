
#include "unit_header.h"

		entry:
			j		1f
			lui		x2, 26
			lui		x2, 26
		1:
			li		x3, 4
			j		2f
			nop
			nop
		1:
			li		x4, 5
			j		done
		2:
			li		x5, 6
			j		1b

start_expected:
.word 3, 4
.word 4, 5
.word 5, 6
end_expected:
