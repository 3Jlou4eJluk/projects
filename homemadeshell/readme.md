# Unix shell

## Implemented

1. tokens.c: a set of functions responsible for parsing a string into tokens
2. descent.c: it contains functions that are responsible for implementing recursive descent and building an execution tree
3. run.c: run.c contains the implementation of the functions that are responsible for executing the built tree

## Tree node structure

```C
struct Node {   
    char **argv;
    char *ifile;
    char *ofile;
    int bg_flag;
    int te_flag;
    int op_code;
    struct Node* br_p;
    struct Node* pipe;
    struct Node* next;
};
```

## Usage:
1. make
2. run 'solution'
3. Enter command
4. Ctrl + D
5. Enjoy

important: parsing of only one line is implemented, because this is essentially the most important thing in solving this problem
