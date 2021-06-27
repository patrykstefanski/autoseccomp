#include <unistd.h>

__attribute__((noinline)) void func_a(void) { syscall(901); }

__attribute__((noinline)) void func_b(void) { syscall(902); }

void (*func_ptr)(void);

__attribute__((noinline)) void set_func_ptr(int argc) {
  if (argc)
    func_ptr = &func_a;
  else
    func_ptr = &func_b;
}

int main(int argc, char **argv) {
  set_func_ptr(argc);
  /* We should allow both syscalls 901 and 902. */
  __builtin_autoseccomp();
  func_ptr();
}
