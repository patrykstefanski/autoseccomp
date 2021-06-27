#include <stdio.h>

int main(void) {
  __builtin_autoseccomp();
  puts("hello world");
}
