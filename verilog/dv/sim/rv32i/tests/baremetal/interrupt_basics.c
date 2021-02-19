/*
 * interrupt_basics.c
 *
 *  Created on: Feb 17, 2021
 *      Author: mballance
 */
#include "baremetal_support.h"

static unsigned int int_count = 0;

static void interrupt(int unsigned cause) {
	// Clear the interrupt
	*((volatile unsigned int *)0x40000004) = 0;
//	print("INT");
	int_count++;
}

int main() {
	int i, x;
	unsigned int old_count;

	set_exception_handler(&interrupt);

	for (i=0; i<4; i++) {
		volatile unsigned int *int_count_p = &int_count;
		old_count = int_count;
		*((volatile unsigned int *)0x40000000) = 100;

		// Wait for an interrupt to occur
		x = 0;
		while (*int_count_p == old_count && x < 100000) {
			x++;
		}

		if (*int_count_p == old_count) {
			record_fail("No interrupt");
		} else if (*int_count_p == old_count+1) {
			record_pass("One interrupt");
		} else {
			record_fail("More than one interrupt");
		}
	}

	if (int_count != 4) {
		record_fail("Too few interrupts");
	}

	endtest();

}

