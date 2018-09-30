#include<stdio.h>
#include<stdlib.h>

typedef struct que{
  int front;				//tracl head of que
  int tail;				//tracl tail of que
  int max;				//max element of int[]
  int used;				//track que usage
  int* arr;				//array of int[]
} que;

que* init(int max){
  que* q = (que*)calloc(1, sizeof(que));
  q->front = 0;				//begin of que
  q->tail = -1;				//tail start at -1 b/c enque increments tail b/4 adding in value
  q->max = max;				//max element of int[]
  q->used = 0;				//nothing in que yet
  q->arr = (int*)calloc(max, sizeof(int));
  return q;
}

void enque(que* q, int item){		//add item to que
  if(q->used == q->max){		//exit of que full
    puts("que full!");
    return;
  }
  q->tail = (q->tail + 1) % (q->max);	//increment tail or wrap back to begining of array
  q->arr[q->tail] = item;		//add the item
  q->used +=1;				//increment used
  printf("eque: %i\n", item);
  for(int i = 0;i < q->max;i++)		//pretty
    printf("%i ", q->arr[i]);
  puts("");
}

int deque(que* q){			//remove item from que
  if(q->used == 0){			//exit if que empty
    puts("nothing in que");
    return -1;
  }
  int tmp = 0;
  tmp = q->arr[q->front];		//temp storage of item from que
  q->arr[q->front] = 0;			//zero out the item
  q->front = (q->front + 1) % (q->max);	//same as tail, move front to next item or wrap it back to begining of array
  q->used -= 1;				//decrement used
  printf("deque: %i\n", tmp);
  for(int i = 0;i < q->max;i++)		//pretty
    printf("%i ", q->arr[i]);
  puts("");
  return tmp;
}

void main(){
  que* q = init(4);			//start with que with 4 element size
  enque(q, 3);				//add 3, 7, 1, 9
  enque(q, 7);
  enque(q, 1);
  enque(q, 9);
  deque(q);				//pop 2 out FIFO
  deque(q);
  enque(q, 55);				//add 55, 11
  enque(q, 11);
  deque(q);				//pop 2 more FIFO
  deque(q);
  enque(q, 100);			//add 100 233
  enque(q, 233);
}
