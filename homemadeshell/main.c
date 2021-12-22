#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include "descent.h"
#include "tokens.h"
#include "run.h"

int main(void) {
    char * str = get_str();
    struct token_arr * toks = make_token_array(str);
    int success = 0;
    struct Node * tree = shell_cmd(toks, &success);
    //printf("descent result: %d\n", success);
    //print_tree(tree, 0);
    if (!success) {
        //printf("Запускаем гуся исполнителя\n");
        success = run_tree(tree);
    }
    destroy_tree(tree);
    free(tree);
    destroy_token_array(toks);
    free(str);
    return success;
}