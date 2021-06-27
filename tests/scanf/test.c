#include <stdio.h>

int main(void) {
  __builtin_autoseccomp();
  int val;
  scanf("%i", &val);
  __builtin_autoseccomp();
  printf("%i\n", val);
  return 0;
}
