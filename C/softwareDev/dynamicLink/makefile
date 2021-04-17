CC=gcc

dome: libfunc1.so func1.h main.c
	$(CC) -Wall main.c -L. -lfunc1 -I. -o main

libfunc1.so: func1.c
	$(CC) -fpic -shared func1.c -o libfunc1.so

clean:
	rm -f libfunc1.so main
