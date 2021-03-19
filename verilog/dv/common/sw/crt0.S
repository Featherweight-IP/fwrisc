/****************************************************************************
 * crt0.S
 *
 * Basic bare-metal boot code
 ****************************************************************************/
.section .text.start, "ax", @progbits
.globl _start
_start:

  mv  x1, x0 // Zero out x1
  mv  x2, x1
  mv  x3, x1
  mv  x4, x1
  mv  x5, x1
  mv  x6, x1
  mv  x7, x1
  mv  x8, x1
  mv  x9, x1
  mv x10, x1
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
  mv x16, x1
  mv x17, x1
  mv x18, x1
  mv x19, x1
  mv x20, x1
  mv x21, x1
  mv x22, x1
  mv x23, x1
  mv x24, x1
  mv x25, x1
  mv x26, x1
  mv x27, x1
  mv x28, x1
  mv x29, x1
  mv x30, x1
  mv x31, x1

  // Setup exception handling
  la t0, exception
  csrw mtvec, t0

  // Initialize stack
  la sp, _stack_top
  addi sp, sp, -4

/*
  // Initialize the global pointer
.option push
.option norelax
  la gp, __global_pointer$
.option pop
 */

#ifndef BSS_CLEARED
  /* clear BSS */
  la x26, _bss_start
  la x27, _bss_end

  bge x26, x27, zero_loop_end

zero_loop:
  sw x0, 0(x26)
  addi x26, x26, 4
  ble x26, x27, zero_loop
zero_loop_end:
#endif /* BSS_CLEARED */

  call main

  // Halt
1:
	j 1b

exception:
	// Save the old sp first
	csrw mscratch, sp
	la sp, exception_stack
	addi sp, sp, 256-4

	// Now, save everything
	sw x1, 0(sp)
	// Note: we'll come back for sp
	sw x3, -8(sp)
	sw x4, -12(sp)
	sw x5, -16(sp)
	sw x6, -20(sp)
	sw x7, -24(sp)
	sw x8, -28(sp)
	sw x9, -32(sp)
	sw x10, -36(sp)
	sw x11, -40(sp)
	sw x12, -44(sp)
	sw x13, -48(sp)
	sw x14, -52(sp)
	sw x15, -56(sp)
	sw x16, -60(sp)
	sw x17, -64(sp)
	sw x18, -68(sp)
	sw x19, -72(sp)
	sw x20, -76(sp)
	sw x21, -80(sp)
	sw x22, -84(sp)
	sw x23, -88(sp)
	sw x24, -92(sp)
	sw x25, -96(sp)
	sw x26, -100(sp)
	sw x27, -104(sp)
	sw x28, -108(sp)
	sw x29, -112(sp)
	sw x30, -116(sp)
	sw x31, -120(sp)

	// Save the original stack pointer
	csrr t0, mscratch
	sw t0, -4(sp)

	// Save the mepc
	csrr t0, mepc
	sw t0, -124(sp)

	// Adjust the sp before calling
	addi sp, sp, -128
	csrr a0, mcause
	la t0, _exception_handler
	jalr ra, t0

	// On return, adjust the sp
	la sp, exception_stack
	addi sp, sp, 256-4

	// Re-load mepc
	lw t0, -124(sp)
	csrw mepc, t0

	// Re-load all registers except old sp
	lw x1, 0(sp)
	// Note: we'll come back for sp
	lw x3, -8(sp)
	lw x4, -12(sp)
	lw x5, -16(sp)
	lw x6, -20(sp)
	lw x7, -24(sp)
	lw x8, -28(sp)
	lw x9, -32(sp)
	lw x10, -36(sp)
	lw x11, -40(sp)
	lw x12, -44(sp)
	lw x13, -48(sp)
	lw x14, -52(sp)
	lw x15, -56(sp)
	lw x16, -60(sp)
	lw x17, -64(sp)
	lw x18, -68(sp)
	lw x19, -72(sp)
	lw x20, -76(sp)
	lw x21, -80(sp)
	lw x22, -84(sp)
	lw x23, -88(sp)
	lw x24, -92(sp)
	lw x25, -96(sp)
	lw x26, -100(sp)
	lw x27, -104(sp)
	lw x28, -108(sp)
	lw x29, -112(sp)
	lw x30, -116(sp)
	lw x31, -120(sp)

	// Restore the original stack pointer
	lw sp, -4(sp)

	// Back where we came from
	mret

