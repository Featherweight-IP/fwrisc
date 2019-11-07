
.section .text.init;

.globl _start
_start:
//	j		wordtest

wordtest:
	li		x1, 0x80008000
	li		x2, 0x55aaeeff
	li		x3, 4
	// Write loop
word_write:
	sw		x2, 0(x1)
	addi	x2, x2, 1
	addi	x1, x1, 4
	addi	x3, x3, -1
	bne		x3, x0, word_write

	// Read loop
	li		x1, 0x80008000
	li		x2, 0x55aaeeff
	li		x3, 4
	li		x4, 0x80008100 // results location
word_read:
	lw		x5, 0(x1)
	bne		x5, x2,	word_read_failed
	li		x6, 1
	beq		x0, x0,	word_read_results
word_read_failed: // passed
	li		x6, 0
word_read_results:
	sw		x6, 0(x4)
//	sw		x5, 0(x4)
	addi	x2, x2, 1
	addi	x1, x1, 4
	addi	x3, x3, -1
	bne		x3, x0, word_read

bytetest:
	li		x1, 0x80008000
	li		x2, 0x55
	li		x3, 4
	// Write loop
byte_write:
	sb		x2, 0(x1)
	addi	x2, x2, 1
	addi	x1, x1, 1
	addi	x3, x3, -1
	bne		x3, x0, byte_write

	// Read loop
	li		x1, 0x80008000
	li		x2, 0x55
	li		x3, 4
	li		x4, 0x80008100 // results location
byte_read:
	lb		x5, 0(x1)
	bne		x5, x2,	byte_read_failed
	li		x6, 1
	beq		x0, x0,	byte_read_results
byte_read_failed: // passed
	li		x6, 0
byte_read_results:
	sw		x6, 0(x4)
//	sw		x5, 0(x4)
	addi	x2, x2, 1
	addi	x1, x1, 1
	addi	x3, x3, -1
	bne		x3, x0, byte_read

end:
	beq		x0, x0,	end
	nop

