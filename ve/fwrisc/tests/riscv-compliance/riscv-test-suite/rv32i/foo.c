

int foo(int x) {
  int i=2;

  for (i=0; i<x; i++) {
    i *= i;
  }

  return i;
}

int main(void) {
  int a = foo(20);
}

  
