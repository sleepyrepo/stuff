#include<stdio.h>
#include<stdlib.h>

typedef struct node{				//B search tree with with value and pointer to child
  int val;
  struct node* left;				//if child < parent
  struct node* right;				//if child >= parent
} node;

node* insert(node* n, int val){			//inser policy, lowest left, then up one to the right
  if(n == NULL){				//if node* is null, its probably a leaf or a new tree
    n = (node*)malloc(sizeof(node));		//get memory for new node
						//very wastful b/c de/allocate small chunks of data all over heap(fragmentation)
						//put all tree nodes in dynamic node[] is way better
    n->val = val;				//set node value
    n->left = NULL;				//null pointer for children
    n->right = NULL;
    return n;					//return the nre node address
  }

  if(val < n->val)				//if new value < node value, go to the left
    n->left = insert(n->left, val);		//recursive down the tree till it finds a leaf
  else
    n->right = insert(n->right, val);		//same recursive but to the right
}

void traverse(node* n){				//search start from root node
  if(n != NULL){				//if node is null, probably end of tree
    traverse(n->left);				//recurse to the most left leaf
    printf("%i ", n->val);			//print it
    traverse(n->right);				//now recurse to right side
  }
}

node* findMin(node* n){				//find min value in a tree given a node
  node* tmp = n;				//use tmp so we dont destroy the node
  while(tmp->left != NULL)
    tmp = tmp->left;				//keep going left til reach the end
  return tmp;					//smallest value in the tree
}

node* del(node* n, int val){			//give a tree(branch), and val, return a new tree with deleted vale
  if(n == NULL) return n;
  if(val < n->val)				//to left if search val smaller
    n->left = del(n->left, val);		//recurse
  else if(val > n->val)				//go right if search vl bigger
    n->right = del(n->right, val);		//recurse
  else{						//found node, start delete it
    if(n->left == NULL){			//condiiton 1 if node is the leaf, delete it
      node* tmp = n->right;			//condition 2 if node has one child, parent with the child
      free(n);
      return tmp;
    }
    else if(n->right == NULL){
      node* tmp = n->left;
      free(n);
      return tmp;
    }
    node* tmp = findMin(n->right);		//condition 3 if node has 2 children
    n->val = tmp->val;				//replace parent with smallest value in right brach
    n->right = del(n->right, tmp->val);		//new delete that child
  }
  return n;
}

void print2D(node* n, int space)
{
    if (n == NULL) return ;			//return if end leaf(left/right NULL)
    space += 1;					//increnert 1 space
    print2D(n->right, space);			//go to the right
    for (int i = 1; i < space; i++)		//print most right node with space
        printf("-");
    printf("%d\n", n->val);
    print2D(n->left, space);			//then print hte left side
}

void main( int argc, char* argv[]){
  if(argc < 2){
    printf("usage: %s 8 4 12 2 14 1 15 3 13 5 11 6 7 9 10\n", argv[0]);
   exit(0);
  }
  node* n = NULL;				//start with a null struct pinter
  node** root = &n;				//struct poonter to pinter to keep track of root tree
  for(int i = 1; i < argc; i++)			//recurse insert the argument
    n = insert(n, atoi(argv[i]));		//smallest number will be written to tje left
  puts("bin search tree..");
  print2D(*root, 0);				//print bin tree in kind of graphic way
  puts("");
  traverse(*root);				//now sort and read the tree back
  int num = 0;
  printf("\npick one to delete: ");
  scanf("%i", &num);				//get value to search/delete from tree
  *root = del(*root, num);			//delete the value and return new tree
  puts("\nnew tree..");
  print2D(*root, 0);
  puts("");
  traverse(*root);				//now sort and read the tree back
  printf("\nadd a num: ");
  scanf("%i", &num);				//get value to add to tree
  insert(*root, num);				//add to tree
  puts("bin search tree..");
  print2D(*root, 0);
  puts("");
  traverse(*root);				//now sort and read the tree back
  puts("");
}

//https://www.geeksforgeeks.org/binary-search-tree-set-2-delete/