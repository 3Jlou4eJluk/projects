#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"
#include "descent.h"


struct Node * node_init(void) {
    struct Node * res = malloc(sizeof(struct Node));
    if (res != NULL) {
        res -> argv = NULL;
        res -> ifile = NULL;
        res -> ofile = NULL;
        res -> bg_flag = 0;
        res -> te_flag = 0;
        res -> op_code = 0;
        res -> br_p = NULL;
        res -> pipe = NULL;
        res -> next = NULL;
    }
    return res;
}

struct Node* shell_cmd(struct token_arr* tks, int * suc_flag) {
    int ct = 0;
    struct Node * head = node_init();
    if (head == NULL) {
        fprintf(stderr, "***shell_cmd: memory is over***\n");
        exit(1);
    }
    if (cmdl(tks, head, &ct)) {
        (*suc_flag) = 1;
    }
    return head;
}

int cmdl(struct token_arr* tks, struct Node* cur_node, int * cur_tok) {
    struct token * arr = tks -> arr;
    if (arr[(*cur_tok)].type == EOL) {
        fprintf(stderr, "***cmdl: EOL not expected***\n");
        return 1;
    }
    if (conv(tks, cur_node, cur_tok)) {
        return 1;
    }
    while (1) {
        if (arr[(*cur_tok)].type == DIVIDER) {
            if (!strcmp(arr[(*cur_tok)].name, "&")) {
                cur_node -> bg_flag = 1;
                (*cur_tok)++;
                if (arr[(*cur_tok)].type == NAME) {
                    struct Node * next_node = node_init();
                    if (next_node == NULL) {
                        fprintf(stderr, "***cmdl: memory is over***\n");
                        exit(1);
                    }
                    cur_node -> next = next_node;
                    cur_node = next_node;
                    if (conv(tks, cur_node, cur_tok)) {
                        return 1;
                    }
                }
            } else if (!strcmp(arr[(*cur_tok)].name, ";")) {
                (*cur_tok)++;
                struct Node* next_node = node_init();
                if (next_node == NULL) {
                    fprintf(stderr, "***cmdl: memory is over***\n");
                    exit(1);
                }
                cur_node -> next = next_node;
                if (arr[(*cur_tok)].type == EOL) {
                    cur_node -> next = NULL;
                    free(next_node);
                    return 0;
                }
                cur_node = cur_node -> next;
                if (conv(tks, cur_node, cur_tok)) {
                    return 1;
                }

            } else if (!strcmp(arr[(*cur_tok)].name, "&&")) {
                cur_node -> op_code = 1;
                (*cur_tok)++;
                struct Node* next_node = node_init();
                if (next_node == NULL) {
                    fprintf(stderr, "***cmdl: memory is over***\n");
                    exit(1);
                }
                cur_node -> next = next_node;
                cur_node = cur_node -> next;
                if (conv(tks, cur_node, cur_tok)) {
                    return 1;
                }
            } else {
                //fprintf(stderr, "***cmdl: this kind of DIVIDER not expected***\n");
                //fprintf(stderr, "DIVIDER: %s\n", arr[(*cur_tok)].name);
                return 0;
            }
        } else {
            return 0;
        }
    }
    return 0;
}

int conv(struct token_arr* tks, struct Node* cur_node, int * cur_tok) {
    struct token * arr = tks -> arr;
    if (arr[(*cur_tok)].type == EOL) {
        fprintf(stderr, "***conv: EOL not expected***\n");
        return 1;
    }
    if (cmd(tks, cur_node, cur_tok)) {
        return 1;
    }
    while ((arr[(*cur_tok)].type == DIVIDER) && 
        !strcmp(arr[(*cur_tok)].name, "|")) {
        (*cur_tok)++;
        if (!((arr[(*cur_tok)].type == NAME) || ((arr[(*cur_tok)].type == DIVIDER) && 
            (!strcmp(arr[(*cur_tok)].name, "("))))) {
            fprintf(stderr, "***conv: parse error***\n");
            exit(1);
        }
        cur_node -> pipe = node_init();
        if (cur_node -> pipe == NULL) {
            fprintf(stderr, "***conv: memory is over***\n");
            exit(1);
        }
        cur_node = cur_node -> pipe;
        if (cmd(tks, cur_node, cur_tok)) {
            return 1;
        }
    }
    return 0;
}

int cmd(struct token_arr* tks, struct Node* cur_node, int * cur_tok) {
    struct token * arr = tks -> arr;
    if (arr[(*cur_tok)].type == EOL) {
        fprintf(stderr, "***cmd: EOL not expected***\n");
        return 1;
    }
    if (arr[(*cur_tok)].type == DIVIDER) {
        if (!strcmp(arr[(*cur_tok)].name, "(")) {
            (*cur_tok)++;
            cur_node -> br_p = node_init();
            if (cur_node -> br_p == NULL) {
                fprintf(stderr, "***cmd: memory is over***\n");
                exit(1);
            }
            if (cmdl(tks, cur_node -> br_p, cur_tok)) {
                return 1;
            }
            if (arr[(*cur_tok)].type != DIVIDER) {
                fprintf(stderr, "***cmd: DIVIDER not expected***\n");
                return 1;
            }
            if (strcmp(arr[(*cur_tok)].name, ")")) {
                fprintf(stderr, "***cmd: parse error***\n");
                return 1;
            }
            // теперь надо проверить наличие ifile и ofile
            (*cur_tok)++;
            for (int i = 0; i < 2; i++) {
                if (arr[(*cur_tok)].type == DIVIDER) {
                    if (!strcmp(arr[(*cur_tok)].name, "<")) {
                        (*cur_tok)++;
                        if (arr[(*cur_tok)].type != NAME) {
                            free(cur_node -> argv);
                            cur_node -> argv = NULL;
                            fprintf(stderr, "***cmd: parse error***\n");
                            return 1;
                        }
                        cur_node -> ifile = arr[(*cur_tok)].name;
                        (*cur_tok)++;
                    } else if (!strcmp(arr[(*cur_tok)].name, ">")) {
                        (*cur_tok)++;
                        if (arr[(*cur_tok)].type != NAME) {
                            free(cur_node -> argv);
                            cur_node -> argv = NULL;
                            fprintf(stderr, "***cmd: parse error***\n");
                            return 1;
                        }
                        cur_node -> ofile = arr[(*cur_tok)].name;
                        (*cur_tok)++;
                    } else if (!strcmp(arr[(*cur_tok)].name, ">>")) {
                        (*cur_tok)++;
                        if (arr[(*cur_tok)].type != NAME) {
                            free(cur_node -> argv);
                            cur_node -> argv = NULL;
                            fprintf(stderr, "***cmd: parse error***\n");
                            return 1;
                        }
                        cur_node -> ofile = arr[(*cur_tok)].name;
                        cur_node -> te_flag = 1;
                        (*cur_tok)++;
                    } else {
                        return 0;
                    }
                } else {
                    return 0;
                }
            }
        } else {
            fprintf(stderr, "***cmd: parse error***\n");
            return 1;
        }
    } else if (arr[(*cur_tok)].type == NAME) {
        if (scmd(tks, cur_node, cur_tok)) {
            return 1;
        }
    } else {
        return 0;
    }
    return 0;
}

int scmd(struct token_arr* tks, struct Node* cur_node, int * cur_tok) {
    cur_node -> ifile = NULL;
    cur_node -> ofile = NULL;
    cur_node -> bg_flag = 0;
    cur_node -> te_flag = 0;
    cur_node -> op_code = 0;
    cur_node -> br_p = NULL;
    cur_node -> pipe = NULL;
    cur_node -> next = NULL;
    struct token * arr = tks -> arr;
    if (arr[(*cur_tok)].type == DIVIDER) {
        fprintf(stderr, "***scmd: parse error***\n");
        return 1;
    }
    if (arr[(*cur_tok)].type == EOL) {
        fprintf(stderr, "***scmd: EOL not expected***\n");
        return 1;
    }
    cur_node -> argv = calloc(START_SIZE, sizeof(char*));
    int ci = 0;
    while ((arr[(*cur_tok)].type != DIVIDER) && (arr[(*cur_tok)].type != EOL)) {
        cur_node -> argv[ci++] = arr[(*cur_tok)++].name;
    }
    cur_node -> argv[ci] = NULL;
    for (int i = 0; i < 2; i++) {
        if (arr[(*cur_tok)].type == DIVIDER) {
            if (!strcmp(arr[(*cur_tok)].name, "<")) {
                (*cur_tok)++;
                if (arr[(*cur_tok)].type != NAME) {
                    free(cur_node -> argv);
                    cur_node -> argv = NULL;
                    fprintf(stderr, "***scmd: parse error***\n");
                    return 1;
                }
                cur_node -> ifile = arr[(*cur_tok)].name;
                (*cur_tok)++;
            } else if (!strcmp(arr[(*cur_tok)].name, ">")) {
                (*cur_tok)++;
                if (arr[(*cur_tok)].type != NAME) {
                    free(cur_node -> argv);
                    cur_node -> argv = NULL;
                    fprintf(stderr, "***scmd: parse error***\n");
                    return 1;
                }
                cur_node -> ofile = arr[(*cur_tok)].name;
                (*cur_tok)++;
            } else if (!strcmp(arr[(*cur_tok)].name, ">>")) {
                (*cur_tok)++;
                if (arr[(*cur_tok)].type != NAME) {
                    free(cur_node -> argv);
                    cur_node -> argv = NULL;
                    fprintf(stderr, "***scmd: parse error***\n");
                    return 1;
                }
                cur_node -> ofile = arr[(*cur_tok)].name;
                cur_node -> te_flag = 1;
                (*cur_tok)++;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    return 0;
}

void print_node(struct Node * node) {
    printf("print_node------------------------------\n");
    int ci = 0;
    if (node -> argv != NULL) {
        printf("command: ");
        while (node -> argv[ci] != NULL) {
            printf("%s ", node -> argv[ci]);
            ci++;
        }
        putchar('\n');
    }
    if (node -> ifile != NULL) {
        printf("ifile: %s\n", node -> ifile);
    }
    if (node -> ofile != NULL) {
        printf("ofile: %s\n", node -> ofile);
    }
    printf("background flag: %d\n", node -> bg_flag);
    printf("writing to end flag: %d\n", node -> te_flag);
    printf("----------------------------------------\n");
}

void print_spaces(int count) {
    for (int i = 0; i < count; i++) {
        putchar(' ');
    }
}

void print_tree(struct Node * node, int counter) {
    print_spaces(counter);
    printf("Printing Node number: %d--------------\n", counter);
    int ci = 0;
    if (node -> argv != NULL) {
        print_spaces(counter);
        printf("command: ");
        while (node -> argv[ci] != NULL) {
            printf("%s ", node -> argv[ci]);
            ci++;
        }
        putchar('\n');
    }
    if (node -> ifile != NULL) {
        print_spaces(counter);
        printf("ifile: %s\n", node -> ifile);
    }
    if (node -> ofile != NULL) {
        print_spaces(counter);
        printf("ofile: %s\n", node -> ofile);
    }
    print_spaces(counter);
    printf("background flag: %d\n", node -> bg_flag);
    print_spaces(counter);
    printf("writing to end flag: %d\n", node -> te_flag);
    print_spaces(counter);
    printf("op_code: %d\n", node -> op_code);
    if (node -> br_p != NULL) {
        print_tree(node -> br_p, counter + 1);
    } else {
        print_spaces(counter);
        printf("br_p is NULL\n");
    }
    if (node -> pipe != NULL) {
        print_tree(node -> pipe, counter + 1);
    } else {
        print_spaces(counter);
        printf("pipe is NULL\n");
    }
    if (node -> next != NULL) {
        print_tree(node -> next, counter + 1);    
    } else {
        print_spaces(counter);
        printf("next is NULL\n");
    }
    print_spaces(counter);
    printf("----------------------------------------\n");
}

void destroy_tree(struct Node * node) {
    //printf("Destroying node:\n");
    //print_node(node);
    if (node -> argv != NULL) {
        free(node -> argv);
        node -> argv = NULL;
    }
    if (node -> br_p != NULL) {
        destroy_tree(node -> br_p);
        free(node -> br_p);
        node -> br_p = NULL;
    }
    if (node -> pipe != NULL) {
        destroy_tree(node -> pipe);
        free(node -> pipe);
        node -> pipe = NULL;
    }
    if (node -> next != NULL) {
        destroy_tree(node -> next);
        free(node -> next);
        node -> next = NULL;
    }
}