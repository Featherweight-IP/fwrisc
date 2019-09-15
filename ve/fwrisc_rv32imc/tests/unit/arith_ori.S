
#include "unit_header.h"

entry:
	li		x1, 5
	ori		x3, x1, 6
	j		done


start_expected:
.word 1, 5
.word 3, 7 // 5|6==7
end_expected:


