
#include "unit_header.h"

entry:
	li		x10, 0

	// Ensure we have the exception vector loaded
	la		x1, exc
	csrw	mtvec, x1

	// Enable interrupts

	// Enable external interrupts
	li		x1, 0x800
	csrw	mie, x1

	// Enable interrupts globally
	li		x1, 0x8
	csrw	mstatus, x1

	// Now, loop
	li		x1, 10

1:
	bltu	x10, x1, 1b

	j		done


.align 16
exc:
	addi	x10, x10, 1

	// First, confirm that everything looks right
	csrr	x2, mcause
	li		x3, 0x80000000
	and		x2, x2, x3
	bne		x2, x0, 1f
	// Fail: expect interrupt bit to be set
	j		done
1:

	csrr	x2, mcause
	li		x3, 0x0000000F
	and		x2, x2, x3
	li		x3, 0xB
	beq		x2, x3, 1f
	j		done

	// Wait for the interrupt to be dropped
1:
	csrr	x2, mip
	li		x3, 0x800
	and		x2, x2, x3
	bne		x2, x0, 1b

	mret



start_expected:
.word 10, 10
end_expected:


