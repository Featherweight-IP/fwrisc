
#include "unit_header.h"

		entry:
			li			x1, 0xf
			li			x2, 0x1
			csrw		mtvec, x1
			csrrc		x1, mtvec, x2

			j			done


start_expected:
.word 1,  0x0f
.word 2,  0x01
.word 0x2D, 0x0e
end_expected:
