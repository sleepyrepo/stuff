#include<stdio.h>
#include<stdlib.h>
#include<string.h>
//https://stackoverflow.com/questions/1350376/function-pointer-as-a-member-of-a-c-struct
typedef struct {
  char* name;                   //name attribure
  char* like;                   //like attribute
  void (*say)(void*);           //method
} puppy;

void say(puppy* myself){                //declare object method
                                //cast type vois to puppy struct
  printf("I'm %s, I like to %s\n", myself->name, myself->like);
}
                                //constructor
puppy* initPuppy(char* name, char* like){
  puppy* p = malloc(sizeof(puppy));     //alloocate new space for puppy
  p->name = name;               //assifn name
  p->like = like;               //assign like
  p->say = (void (*)(void*))&say;//assign method address, cast to function pointer
  return p;                     //return new opject
}

int main(){                     //instantiate puppy
                                //in OOP, this would be like pup1 = new puppy("some_string...")
  puppy* pup1 = initPuppy("wiggles", "run run run!!");
  puts(pup1->name);
  puts(pup1->like);
  pup1->say(pup1);              //call puppy say instant method by passing in the instant address(self)

  puppy* pup2 = initPuppy("sleepy", "laaaayyyyyddddooowwwnnnnnn...");
  puts(pup2->name);
  puts(pup2->like);
  pup2->say(pup2);

  free(pup1);
  free(pup2);
  return 0;
}
