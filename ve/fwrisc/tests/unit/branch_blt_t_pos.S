
#include "unit_header.h"

		entry:
			li		x1, 5
			li		x2, 6
			blt		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done

start_expected:
.word 1, 5
.word 2, 6
.word 3, 24
end_expected:
