#include<stdio.h>
#include<func1.h>

int main(){
  Super super;				//struct from func1.h
  super.str = "super duper struct!!";
  struct Lame lame;			//same
  lame.str = "super lame struct!!";
  printf("doing main stuff :P\n");
  printf("\n%s\n", super.str);
  printf("%s\n\n", lame.str);
  funcOne();				//function from func1.c source file
  printf("back to main stuff :D\n");
  return 0;
}
/*
gcc -c func1.c				//create func1.o object file
ar rcs libfunc1.a *.o			//create/replace/index archieve from all object files
ar -t libfunc1.a			//list files in archieve
gcc main.c -I. -L. -lfunc1 -o main	//order is important
  -I. iclude file path "."
  -L. dd lib file path "."
  -l static lib name
*/
