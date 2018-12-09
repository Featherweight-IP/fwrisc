
#include "unit_header.h"

		entry:
			csrr		x1, mcause
			j			done


start_expected:
.word 1, 0
end_expected:
