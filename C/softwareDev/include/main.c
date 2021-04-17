#include<stdio.h>
#include<func1.h>			//header file
//char* funcOne();                      //can be replaced with a line "char* funcOne();" since that all hte file is
                                        //cc main.c func1.c -I. -o main
					//combine main.c and func1.c source file
                                        //compile main.c, func1.c and include files(-I) in this dir "." into main

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

