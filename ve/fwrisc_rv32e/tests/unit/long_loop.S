
#include "unit_header.h"

		entry:
			li		x1, 0
			li		x2, 5000000
		1:
			addi		x1, x1, 1
			bne		x1, x2, 1b
			j		done


start_expected:
.word 1, 10000000
.word 2, 10000000
end_expected:
