# Unix shell

## Implemented

1. tokens.c: a set of functions responsible for parsing a string into tokens
2. descent.c: it contains functions that are responsible for implementing recursive descent and building an execution tree
3. run.c: contains the implementation of the functions that are responsible for executing the built tree

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

- char **argv - аrray of subcommand arguments
- char *ifile - intput file for subcommand
- char *ofile - output file for subcommand
- int bg_flag - background mod flag for subcommand
- int op_code - the result of the subcommand is stored here
- struct Node* br_p - if the subcommand is of bracket type, then this is a pointer to the subtree corresponding to the expression in brackets
- struct Node* pipe - pointer to the next element of the pipeline
- struct Node* next - pointer to the subtree of the next command

## Usage:
1. make
2. run 'solution'
3. Enter command
4. Ctrl + D
5. Enjoy

important: parsing of only one line is implemented, because this is essentially the most important thing in solving this problem
