
#include "unit_header.h"

		entry:
			li		x1, 5
			csrw		mscratch, x1
			csrr		x2, mscratch

			j		done


start_expected:
.word 0x01,  5
.word 0x02,  5
.word (0x28+2),  5
end_expected:
