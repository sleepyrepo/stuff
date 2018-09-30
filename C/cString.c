#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef struct{                         //create struct array
  char* p;                              //pointer to string
  int size;                             //str len, b/c malloc never returns allocated memory size
} Array;

void main(int argc, char* argv[]){

if(argc < 2){
  printf("needs arg strings!!\ni.e %s $(perl -e 'print\"A\"x2000 .\"\\n\"')\n",argv[0]);
  exit(0);
}

Array arr;
int init = 10;

if(arr.p = (char*) malloc(init)) perror("malloc");
arr.size = init;

if((strlen(argv[1]) + 1) > arr.size){   //if string bigger than buffer, realoc
  arr.p = (char*) realloc(arr.p, strlen(argv[1]) + 1);  //returns different address but with the same data content
  arr.size = strlen(argv[1]) + 1;       //set array size var
}

strcpy(arr.p, argv[1]);         	//do the copy

puts(arr.p);

free(arr.p);

}