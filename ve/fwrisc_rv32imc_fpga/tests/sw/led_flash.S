
.section .text.init;

.globl _start
_start:
	li		x1, 0xc0000000;
	li		x2, 0x0
	li		x4, 0x80002000;
	sb		x2, 0(x4)
1:
	lb		x3, 0(x4)
	sw		x3, 0(x1)
	addi		x3, x3, 1
	sb		x3, 0(x4)
	j		1b
	nop

