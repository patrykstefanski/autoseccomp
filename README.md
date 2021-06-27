# AutoSeccomp

An Automated Approach for Generation of Seccomp System Call Filters

## Overview

AutoSeccomp is an extension of the LLVM framework that simplifies securing C applications with seccomp.
It provides a new builtin - `__builtin_autoseccomp()`, which can be used to mark a program point where seccomp-bpf rules should be generated and installed to reduce the set of allowed system calls.
AutoSeccomp will automatically compute a sound set of system calls and generate the corresponding rules.

AutoSeccomp currently:

* Supports only x86-64
* Supports only static builds
* Supports only musl C standard library
* Considers only syscall numbers, ignoring other syscall arguments

AutoSeccomp manages to build the following applications and reduce the number of allowed system calls in the serving phase:

* nginx - 72/440 (16.36%) allowed
* redis-server - 81/440 (18.41%) allowed
* memcached - 54/440 (12.27%) allowed

AutoSeccomp is still work-in-progress, do not use in production!

## Building

You will need:

* clang and lld
* CMake
* Ninja
* Python 3

Build the modified LLVM and musl, as well as the runtime library:

```bash
./scripts/build-llvm.sh
./scripts/build-musl.sh
./scripts/build-runtime.sh
```

Now, you can build the patched apps.
For example:

```bash
cd apps/nginx
./build.sh
```

You can source the `env.sh` file, which allows to use `autoseccomp-clang`:

```bash
source ./env.sh
autoseccomp-clang -o prog prog.c
```

You can check [tests](tests) for a few simple programs.


## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
