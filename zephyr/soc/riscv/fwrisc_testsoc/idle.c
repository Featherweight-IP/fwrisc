/*
 * Copyright (c) 2018 Matthew Ballance <matt.ballance@gmail.com>
 *
 * Idle routines for the FWRISC core. Since this core doesn't
 * support interrupts, time and events are supported by reading
 * the MCYCLE register and emitting events as needed
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <toolchain.h>
#include <irq.h>
#include <soc.h>
// #include <drivers/system_timer.h>

// #include <tracing.h>

static uint32_t last_mcycle = 0;

#define CYCLES_PER_TICK (CONFIG_SYS_CLOCK_HW_CYCLES_PER_SEC/CONFIG_SYS_CLOCK_TICKS_PER_SEC)

/**
 *
 * @brief Power save idle routine
 *
 * This function will be called by the kernel idle loop or possibly within
 * an implementation of _sys_power_save_idle in the kernel when the
 * '_sys_power_save_flag' variable is non-zero.
 *
 * Need to issue an event after (
 * SYS_CLOCK_HW_CYCLES_PER_SEC ; SYS_CLOCK_TICKS_PER_SEC
 *
 * @return N/A
 */
void k_cpu_idle(void)
{
	last_mcycle += CYCLES_PER_TICK;
	z_clock_announce(1);

#ifdef UNDEFINED
	u32_t mcycle;

	while (1) {
		__asm__ volatile("csrr %0, mcycle" : "=r"(mcycle));

		if ((mcycle-last_mcycle) >= CYCLES_PER_TICK) {
			z_clock_announce(1);
			last_mcycle = mcycle;
			break;
		}
	}

#endif
	// Make a system call to trigger thread rescheduling
	__asm__ volatile("ecall");
}

uint32_t z_clock_elapsed(void) {
	return last_mcycle;
}

/**
 *
 * @brief Atomically re-enable interrupts and enter low power mode
 *
 * INTERNAL
 * The requirements for k_cpu_atomic_idle() are as follows:
 * 1) The enablement of interrupts and entering a low-power mode needs to be
 *    atomic, i.e. there should be no period of time where interrupts are
 *    enabled before the processor enters a low-power mode.  See the comments
 *    in k_lifo_get(), for example, of the race condition that
 *    occurs if this requirement is not met.
 *
 * 2) After waking up from the low-power mode, the interrupt lockout state
 *    must be restored as indicated in the 'imask' input parameter.
 *
 * @return N/A
 */
void k_cpu_atomic_idle(unsigned int key)
{
	k_cpu_idle();
}
