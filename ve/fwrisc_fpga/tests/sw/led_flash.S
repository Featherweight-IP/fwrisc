
.section .text.init;

.globl _start
_start:
	li		x1, 0xc0000000;
	li		x2, 0x0
1:
	srli	x3, x2, 26
	sw		x3, 0(x1)
	addi	x2, x2, 1
	j		1b
	nop

