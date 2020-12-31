
#include "unit_header.h"

		entry:
			jal		x1, 1f
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry
			sub		x4, x1, x3
			li		x1, 0
			li		x3, 0
			j		done
start_expected:
.word 1, 0
.word 3, 0
.word 4, 4
end_expected:
