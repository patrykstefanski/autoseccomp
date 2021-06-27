#include <stdio.h>

/*
 * A test to see what happens when we hit the limit of total seccomp-bpf
 * instructions.
 */
int main(void) {
  for (unsigned i = 0; i < 1000; ++i) {
    __builtin_autoseccomp();
    printf("%u\n", i);
  }
  return 0;
}
