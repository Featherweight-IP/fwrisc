/*
 * baremetal_support.h
 *
 *  Created on: Feb 17, 2021
 *      Author: mballance
 */

#ifndef INCLUDED_BAREMETAL_SUPPORT_H
#define INCLUDED_BAREMETAL_SUPPORT_H

extern unsigned int outstr_addr;

void outstr(const char *s);

void print(const char *m);

void record_pass(const char *m);

void record_fail(const char *m);

void test_pass();

void test_fail();

void endtest();

typedef void (*exception_f)(int unsigned cause);

void set_exception_handler(exception_f f);



#endif /* INCLUDED_BAREMETAL_SUPPORT_H */
