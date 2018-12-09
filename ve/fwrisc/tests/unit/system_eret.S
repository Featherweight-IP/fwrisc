
#include "unit_header.h"

		entry:
			la			x1, pass
			csrw		mepc, x1
			mret
			j			done
		pass:
			li			x1, 0
			li			x2, 25
			csrw		mepc, x1
			j			done


start_expected:
.word 0x01,  0
.word 0x02,  25
.word 0x29,  0x00000000 // MEPC
end_expected:
