
#include "unit_header.h"

		entry:
			csrr		x1, mcause
			j			done


start_expected:
.word 1, 0
.word (0x30+2), 0
end_expected:
