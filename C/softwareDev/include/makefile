CFLAGS=-Wall
CC=gcc

dome: main.c func1.c func1.h				#target: required source files
	$(CC) $(CFLAGS) -o main main.c func1.c -I.
clean:
	rm -r ./main

