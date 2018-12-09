
#include "unit_header.h"

		entry:
			li			x1, 5
			csrw		mtvec, x1
			csrr		x2, mtvec

			j			done


start_expected:
.word 1, 5
.word 2, 5
.word 37, 5
end_expected:
