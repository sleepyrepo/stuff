CC=gcc

dome: libfunc1.a func1.h main.c
	$(CC) -Wall main.c -L. -lfunc1 -I. -o main

libfunc1.a: func1.o
	ar rcs libfunc1.a func1.o

func1.o: func1.c
	$(CC) -c func1.c

clean:
	rm -f libfunc1.a main func1.o
