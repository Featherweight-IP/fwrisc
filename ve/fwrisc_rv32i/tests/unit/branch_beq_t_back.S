
#include "unit_header.h"

		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
		t_start:
			li		x1, 5
			li		x2, 5
			beq		x1, x2, 1b
		2: // fail
			li		x3, 20
			j		done


start_expected:
.word 1, 5
.word 2, 5
.word 3, 24
end_expected:
