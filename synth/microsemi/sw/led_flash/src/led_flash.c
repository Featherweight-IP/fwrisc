
#include <stdint.h>

int main(void) {
  volatile uint32_t *led = (volatile uint32_t)0xC0000000;
  uint32_t count = 0;


  while (1) {
    *led = count;
    count++;
  }

  return 0;
}

