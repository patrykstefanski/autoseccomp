#include <linux/audit.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <syscall.h>
#include <unistd.h>

#define AUTOSECCOMP_ENABLE_DEBUG 0

#if AUTOSECCOMP_ENABLE_DEBUG

static long __autoseccomp_syscall3(long n, long a1, long a2, long a3) {
  long ret;
  __asm__ __volatile__("syscall"
                       : "=a"(ret)
                       : "a"(n), "D"(a1), "S"(a2), "d"(a3)
                       : "rcx", "r11", "memory");
  return ret;
}

static void __autoseccomp_write(int fd, const void *buf, size_t count) {
  __autoseccomp_syscall3(SYS_write, fd, (long)buf, (long)count);
}

static void __autoseccomp_write_addr(unsigned long addr) {
  char buf[16];
  for (unsigned i = 0; i < 16; i++) {
    buf[15 - i] = "0123456789abcdef"[(addr >> (i * 4)) & 0xf];
  }
  __autoseccomp_write(STDERR_FILENO, buf, 16);
}

static void __autoseccomp_write_uint(unsigned n) {
  char buf[10], *end = &buf[10], *p = end;
  while (n != 0 || p == end) {
    *--p = '0' + (n % 10);
    n /= 10;
  }
  __autoseccomp_write(STDERR_FILENO, p, (unsigned long)(end - p));
}

#define DEBUG_STR(s) __autoseccomp_write(STDERR_FILENO, s, sizeof(s) - 1)
#define DEBUG_ADDR(addr) __autoseccomp_write_addr(addr)
#define DEBUG_UINT(n) __autoseccomp_write_uint(n)

#else

#define DEBUG_STR(s)
#define DEBUG_ADDR(addr)
#define DEBUG_UINT(n)

#endif

static long __autoseccomp_syscall5(long n, long a1, long a2, long a3, long a4,
                                   long a5) {
  long ret;
  register long r10 __asm__("r10") = a4;
  register long r8 __asm__("r8") = a5;
  __asm__ __volatile__("syscall"
                       : "=a"(ret)
                       : "a"(n), "D"(a1), "S"(a2), "d"(a3), "r"(r10), "r"(r8)
                       : "rcx", "r11", "memory");
  return ret;
}

static int __autoseccomp_prctl(int option, unsigned long arg2,
                               unsigned long arg3, unsigned long arg4,
                               unsigned long arg5) {
  return (int)__autoseccomp_syscall5(SYS_prctl, option, (long)arg2, (long)arg3,
                                     (long)arg4, (long)arg5);
}

#define MAX_SYSCALL_NUMBER 1024u

#define ADD(f) filter[n++] = (struct sock_filter)f;

void __autoseccomp_restrict(const uint8_t *syscalls) {
  struct sock_filter filter[MAX_SYSCALL_NUMBER * 2 + 5];
  struct sock_fprog prog;
  uint16_t n = 0;
  int ret;

  DEBUG_STR("[autoseccomp] addr=");
  DEBUG_ADDR((unsigned long)__builtin_return_address(0));
  DEBUG_STR(":");

  ADD(BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
               (offsetof(struct seccomp_data, arch))));
  ADD(BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, AUDIT_ARCH_X86_64, 1, 0));
  ADD(BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS));

  ADD(BPF_STMT(BPF_LD | BPF_W | BPF_ABS, (offsetof(struct seccomp_data, nr))));

  for (unsigned i = 0u; i < MAX_SYSCALL_NUMBER / 8u; i++) {
    uint8_t byte = syscalls[i];
    for (unsigned j = 0u; j < 8u; j++) {
      unsigned nr = i * 8u + j;
      bool allowed = (byte & (1u << j)) != 0;
      if (allowed) {
        DEBUG_STR(" ");
        DEBUG_UINT(nr);
      }
      if (allowed || (AUTOSECCOMP_ENABLE_DEBUG && nr == SYS_write)) {
        ADD(BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, nr, 0, 1));
        ADD(BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW));
      }
    }
  }

  DEBUG_STR("\n");

  ADD(BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS));

  ret = __autoseccomp_prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
  if (ret != 0) __builtin_trap();

  prog.filter = filter;
  prog.len = n;
  ret = __autoseccomp_prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER,
                            (unsigned long)&prog, 0, 0);
  if (ret != 0) __builtin_trap();
}
