
#include "unit_header.h"

		entry:
			csrwi		mtvec, 4
			csrr		x2, mtvec
			csrrsi		x3, mtvec, 1
			csrr		x4, mtvec

			j			done


start_expected:
.word 2,  4
.word 3,  4
.word 4,  5
.word 0x2d, 5
end_expected:
