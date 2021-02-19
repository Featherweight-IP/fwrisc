/*
 * baremetal_support.c
 *
 *  Created on: Feb 17, 2021
 *      Author: mballance
 */
#include "baremetal_support.h"

unsigned int outstr_addr;
static unsigned int n_pass = 0;
static unsigned int n_fail = 0;

unsigned int exception_stack[64];

static exception_f handler = 0;

void _exception_handler(int unsigned cause) {
	if (handler) {
		handler(cause);
	} else {
		record_fail("Exception with no handler");
	}
}

void set_exception_handler(exception_f f) {
	handler = f;
}

void enable_interrupts() {
	unsigned int mie;
    __asm__ volatile ("csrrs %0, mie, %1\n"
                      : "=r" (mie)
                      : "r" (1 << 11));
}

void disable_interrupts() {
	unsigned int mie;
    __asm__ volatile ("csrrc %0, mie, %1\n"
                      : "=r" (mie)
                      : "r" (1 << 11));
}

void outstr(const char *m) {
	const char *p = m;
	volatile unsigned int *out_p = &outstr_addr;

	while (*p) {
		*out_p = *p;
		p++;
	}
}

void print(const char *m) {
	outstr(m);
	outstr("\n");
}

void record_pass(const char *m) {
	outstr("PASS: ");
	outstr(m);
	outstr("\n");
	n_pass++;
}

void record_fail(const char *m) {
	outstr("FAIL: ");
	outstr(m);
	outstr("\n");
	n_fail++;
}

void test_pass() {
	while (1) {
		;
	}
}

void test_fail() {
	while (1) {
		;
	}
}

void endtest() {
	if (n_fail) {
		test_fail();
	} else if (n_pass) {
		test_pass();
	} else {
		test_fail();
	}
}


