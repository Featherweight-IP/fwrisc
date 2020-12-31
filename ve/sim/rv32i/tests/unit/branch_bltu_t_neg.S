
#include "unit_header.h"

		entry:
			li		x1, 0x80000000
			li		x2, 0x80000001
			bltu	x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done

start_expected:
.word 1, 0x80000000
.word 2, 0x80000001
.word 3, 24
end_expected:
