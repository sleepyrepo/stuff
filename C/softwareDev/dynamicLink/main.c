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
gcc -fpic -shared func1.c -o libfunc1.so	//compile .so
gcc -L. -lfunc1 -I. main.c -o main
-L. add "." to lib load path
-l link libfunc1.so
-I. add "." to include file path
LD_LIBRARY_PATH=. ./main			//add "." to runtime lib load path

more permanent runtime load
op 1) cp ./libfunc.so /usr/lib/                                         //copy the .so to known runtime lib load path
op 2) ldconfig /root/Desktop/myC/libLink                                //add runtime load path using ldconfig
									// **gone if /etc/ld.so.cache gets rebuild (ldconfig)
op 2) echo "/root/Desktop/myC/libLink" > /etc/ld.so.conf.d/myLib.conf   //add a runtime load path config to ld conf.d/
                                                                        //or append this path to one of hte file in the dir
echo "/root/Desktop/myC/libLink" >> /etc/ld.so.conf                     //append load path to ls.so.conf file
ldconfig -v | grep : -B2                                                //reload the load/show ld load path cache
op 3) export LD_LIBRARY_PATH=/root/Desktop/myC/libLink                  //set ld load path env
env | grep -i path
unset LD_LIBRARY_PATH                                                   //remove env

*/
