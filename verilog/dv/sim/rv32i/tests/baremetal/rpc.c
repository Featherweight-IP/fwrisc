
#include "baremetal_support.h"

static int a=0;

void func_c(char a) {

}

void func_sh(short a) {

}

void func_i(int a) {

}

void func_l(long long a) {

}

void func_s(const char *s) {

}

int main() {
	int i;

	for (i=0; i<100; i++) {
		print("Hello [%d] %d %d %d %d %d", i, 1000+i, 200*i, 300*i, 4, 5);
	}
	/*
	func_c(1);
	func_c(-1);
//	func_sh(1);
//	func_sh(-1);
	func_s("Hello World");
	 */
}
