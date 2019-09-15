# Zephyr Port

The FWRISC Zephyr port consists of SoC and Board files derived from the relevant files for Pulpino and risc-privilege. 

The only somewhat-unique aspect of porting Zephyr to FWRISC is that FWRISC does not (currently) support interrupts. 
As a consequence, measuring time is done by polling the MCYCLE CSR instead of waiting for timer interrupts to occur.
This also means that Zephyr does not currently support truly-preemptive multitasking.

 
## Porting Tasks

### Creating a dummy Timer Driver
Zephyr appears to assume that a timer driver exists. Consequently, a stub fwrisc_timer driver (drivers/timer/fwrisc_timer.c) 
was created. This is a completely-NOP implementation.

### Implementing the Idle Routine
Zephyr applications still need to tell time, so we need an alternative to a timer interrupt. The FWRISC Zephyr port
enables keeping time via an implementation of the k_cpu_idle function that issues a clock event every N 
MCYCLE counts.

```
void k_cpu_idle(void)
{
	u32_t mcycle;

	while (1) {
		__asm__ volatile("csrr %0, mcycle" : "=r"(mcycle));

		if ((mcycle-last_mcycle) >= CYCLES_PER_TICK) {
			z_clock_announce(1);
			last_mcycle = mcycle;
			break;
		}
	}

	// Make a system call to trigger thread rescheduling
	__asm__ volatile("ecall");
}
```

### Security Features
The FWRISC port uses a kernel-startup hook to enable data-execution prevention
just after the kernel boots and before the main application runs. See 
soc/riscv32/fwrisc/common/soc.c for the code.

```
static int soc_init(struct device *dev) {
  intptr_t start = (intptr_t)&_image_rom_start;
  intptr_t end = (intptr_t)&_image_text_end;

  start |= 1;
  end |= 1;

  __asm__ ( "csrw 0xBC0, %[value]" 
	: 
	:[value]"r" (start)
	:
  );
  __asm__ ( "csrw 0xBC1, %[value]" 
	: 
	:[value]"r" (end)
	:
  );
}

SYS_INIT(soc_init, PRE_KERNEL_1, 99);
```


### Boards

The FWRISC port of Zephyr defines two boards:
- fwrisc_sim -- A board definition for use with RTL simulation targets. Uses the RAM console, and defines the clock frequency so as to shorten simulation runs.
- fwrisc_fpga -- A board definition for use with FPGA platforms. Uses a UART console and defines the clock frequency appropriately

