#include <unistd.h>

int main(void) {
  __builtin_autoseccomp();
  setuid(1000);
  return 0;
}
