
#include "unit_header.h"

		entry:
			li			x1, 5
			csrw		medeleg, x1
			csrr		x2, medeleg

			j			done


start_expected:
.word 0x01,  5
.word 0x02,  5
.word 0x22,  5
end_expected:
