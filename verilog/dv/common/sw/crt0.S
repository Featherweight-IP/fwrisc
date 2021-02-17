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

  /* clear BSS */
  la x26, _bss_start
  la x27, _bss_end

  bge x26, x27, zero_loop_end

zero_loop:
  sw x0, 0(x26)
  addi x26, x26, 4
  ble x26, x27, zero_loop
zero_loop_end:

  call main

  // Halt
1:
	j 1b


