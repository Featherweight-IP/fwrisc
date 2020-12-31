
#include "unit_header.h"

entry:
	lui		x1, 5
	j		done

// Expected value for registers
start_expected:
.word 1, 0x00005000
end_expected:
