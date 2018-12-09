
#include "unit_header.h"

		entry:
			li			x1, 4
			csrw		mtvec, x1
			csrr		x2, mtvec
			li			x1, 1
			csrrs		x3, mtvec, x1
			csrr		x4, mtvec

			j			done


start_expected:
.word 1,  1
.word 2,  4
.word 3,  4
.word 4,  5
.word 37, 5
end_expected:
