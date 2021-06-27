#include <pthread.h>
#include <stdio.h>

static void *thread_proc(void *arg) {
  __builtin_autoseccomp();
  puts("hello world");
  return NULL;
}

int main(void) {
  __builtin_autoseccomp();
  pthread_t t;
  pthread_create(&t, NULL, thread_proc, NULL);
  pthread_join(t, NULL);
  return 0;
}
