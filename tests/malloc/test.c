#include <stdlib.h>

int main(void) {
  __builtin_autoseccomp();
  void *p = malloc(1024);
  return 0;
}
