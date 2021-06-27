all:
	autoseccomp-clang -O3 -c test.c -o test.o
	llvm-dis test.o -o test.ll
	autoseccomp-clang test.o -o test

clean:
	rm -f test test.o test.ll test.*Graph.dot out
