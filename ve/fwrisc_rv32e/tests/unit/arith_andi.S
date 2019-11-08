
#include "unit_header.h"

entry:
	li		x1, 5
	andi	x3, x1, 4
	j		done

start_expected:
.word 1, 5
.word 3, 4 // 5&6==4
end_expected:


