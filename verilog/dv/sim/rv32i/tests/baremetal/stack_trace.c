/****************************************************************************
 * stack_trace.c
 *
 * Used in testing the trace BFM for call-stack monitoring
 ****************************************************************************/

void f1(int depth);
void f2(int depth);
void f3(int depth);
void f4(int depth);
void f5(int depth);
void f6(int depth);
void f7(int depth);
void f8(int depth);
void f9(int depth);
void f10(int depth);

void f1(int depth) {
	if (depth > 0) {
		f2(depth-1);
	}
}

void f2(int depth) {
	if (depth > 0) {
		f3(depth-1);
	}
}

void f3(int depth) {
	if (depth > 0) {
		f4(depth-1);
	}
}

void f4(int depth) {
	if (depth > 0) {
		f5(depth-1);
	}
}

void f5(int depth) {
	if (depth > 0) {
		f6(depth-1);
	}
}

void f6(int depth) {
	if (depth > 0) {
		f7(depth-1);
	}
}

void f7(int depth) {
	if (depth > 0) {
		f8(depth-1);
	}
}

void f8(int depth) {
	if (depth > 0) {
		f9(depth-1);
	}
}

void f9(int depth) {
	if (depth > 0) {
		f10(depth-1);
	}
}

void f10(int depth) {
}

int main() {
	int i;

//	f1(7);
	for (i=0; i < 10; i++) {
		f1(i);
	}
}

