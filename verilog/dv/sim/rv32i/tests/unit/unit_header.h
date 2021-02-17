/****************************************************************************
 * unit_header.h
 *
 * Prefix for all unit tests
 ****************************************************************************/
.section .text.init;
.globl _start
_start:
	j		test_program
done:
	j		done
test_program:	// 

