/*
 * baremetal_support.c
 *
 *  Created on: Feb 17, 2021
 *      Author: mballance
 */
#include "baremetal_support.h"
#include <stdint.h>

// Address for RAM console
unsigned int outstr_addr;

static unsigned int n_pass = 0;
static unsigned int n_fail = 0;

core_data_t core_data[N_CORES];
const uint32_t sizeof_core_data_s = sizeof(core_data_t);

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

void config_nonprimary(
		uint32_t		core,
		uint32_t 		*sp,
		void (*main_f)(uint32_t)) {
	core_data[core].sp = sp;
	core_data[core].main_f = main_f;

	// Send an interrupt to the appropriate core
	*((volatile uint32_t *)(0x40000000+(0x100*core)+8)) = 1;
}

uint32_t coreid() {
	uint32_t ret;
	__asm__ volatile("csrr %0, mhartid" : "=r" (ret));
	return ret;
}

/**
 * Send a string to the RAM console for the
 * testbench to display
 */
void outstr(const char *m) {
	const char *p = m;
	volatile unsigned int *out_p = &outstr_addr;

	while (*p) {
		*out_p = *p;
		p++;
	}
}

void outc(char c) {
	volatile unsigned int *out_p = &outstr_addr;
	*out_p = c;
}

void println(const char *m) {
#ifdef RAMCONSOLE
	outstr(m);
	outstr("\n");
#endif
}

void record_pass(const char *m) {
#ifdef RAMCONSOLE
	print("PASS: ");
	print(m);
	print("\n");
#endif
	n_pass++;
}

void record_fail(const char *m) {
#ifdef RAMCONSOLE
	print("FAIL: ");
	print(m);
	print("\n");
#endif
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

void print(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	vprint(fmt, ap);
	va_end(ap);
}

void vprint(const char *fmt, va_list ap) {
#ifdef RAMCONSOLE
	const char *p = fmt;

	while (*p) {
		if (*p == '%') {
			p++;
			if (*p == 'd') {
				int32_t idx = 0;
				char tmp[16];
				uint32_t val = va_arg(ap, uint32_t);
				// Print decimal
				do {
					tmp[idx] = '0'+(val%10);
					val /= 10;
					idx++;
				} while (val);
				while (idx--) {
					outc(tmp[idx]);
				}
			} else if (*p == 'x') {
				int32_t idx = 0;
				char tmp[16];
				uint32_t val = va_arg(ap, uint32_t);
				// Print hex
				do {
					int d = (val % 16)
					if (d < 10) {
						tmp[idx] = '0'+d;
					} else {
						tmp[idx] = 'a'+d;
					}
					val /= 16;
					idx++;
				} while (val);
				while (idx--) {
					outc(tmp[idx]);
				}
			} else if (*p == 's') {
				const char *sp = va_arg(ap, const char *)
				while (*sp) {
					outc(*sp);
					sp++;
				}
			}
		} else {
			outc(*p);
		}
		p++;
	}
#endif
}


