#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include "tokens.h"

/*
    разделителем может быть любой управляющий символ,
    перенос строки, либо конец файла(будем добавлять
    нулевой символ в конце каждой считываемой строки)
*/
int div_check(int sym) {
    if ((sym == '&') || (sym == '|') || (sym == ';') || (sym == '>') || 
        (sym == '<') || (sym == '(') || (sym == ')') || (sym == ' ') || 
        (sym == '\0') || (sym == '\n')) {
        return 1;
    } else {
        return 0;
    }
}

/*
    Не подавать сюда обработанный токен. Будет утечка.
*/

int get_token(char* str, int reload_flag, struct token * tok) {
    static long shift = 0;
    static long len = 0;
    if (reload_flag || !len) {
        shift = 0;
        len = strlen(str);
        if (!len) {
            return 1;
        }
    }

    tok -> type = NAME;
    tok -> name = NULL;
    int cs = START_SIZE;
    char * tmp_chr_ptr = NULL;
    char * name = calloc(START_SIZE, sizeof(char));
    while(str[shift] == ' ') {
        shift++;
    }
    if (div_check(str[shift])) {
        free(name);
        tok -> type = DIVIDER;
        name = calloc(3, sizeof(char));
        switch(str[shift]) {
            case '|':
            case ';':
            case '(':
            case ')':
            case '<':
                name[0] = str[shift];
                name[1] = '\0';
                tok -> name = name;
                shift++;
                return 0;
            case '\n':
            case '\0':
                free(name);
                tok -> type = EOL;
                shift = 0;
                return 0;
            case '&':
            case '>':
                name[0] = str[shift];
                if (str[shift + 1] == str[shift]) {
                    name[1] = str[shift];
                    name[2] = '\0';
                    shift += 2;
                } else {
                    name[1] = '\0';
                    shift += 1;
                }
                tok -> name = name;
                return 0;
            default:
                // сюда попасть так-то анрил, 
                // но компилер будет ругаться если не оставить
                // UPD: сюда попасть вполне рил
                free(name);
                return 1;
        }
    }
    int ci = 0;
    while(!div_check(str[shift])) {
        if (ci == cs) {
            cs *= DYN_COEF;
            tmp_chr_ptr = realloc(name, cs * sizeof(*tmp_chr_ptr));
            if (tmp_chr_ptr == NULL) {
                free(name);
                free(tok);
                fprintf(stderr, "***get_token: ERROR, memory is over***\n");
                exit(1);
            }
            name = tmp_chr_ptr;
        }
        name[ci++] = str[shift++];
    }
    name[ci] = '\0';
    tok -> name = name;
    return 0;
}

char* get_str(void) {
    int c;
    int cs = START_SIZE;
    int ci = 0;
    char * tmp_chr_ptr;
    char * res = calloc(START_SIZE, sizeof(char));
    while (((c = getchar()) != EOF)) {
        if (ci == cs) {
            cs *= DYN_COEF;
            tmp_chr_ptr = realloc(res, cs * sizeof(char));
            if (tmp_chr_ptr == NULL) {
                free(res);
                fprintf(stderr, "***get_str: ERROR, memory is over***\n");
                exit(1);
            }
            res = tmp_chr_ptr;
        }
        if ((char)c == '\n') {
            res[ci++] = ' ';
            continue;
        }
        res[ci++] = (char)c;
    }
    if (ci == cs) {
        cs += 2;
        tmp_chr_ptr = realloc(res, cs * sizeof(char));
        if (tmp_chr_ptr == NULL) {
            free(res);
            fprintf(stderr, "***get_str: ERROR, memory is over***\n");
            exit(1);
        }
        res = tmp_chr_ptr;
    }
    res[ci] = '\0';
    return res;
}

/*
char* get_str(void) {
    int c;
    int cs = START_SIZE;
    int ci = 0;
    char * tmp_chr_ptr;
    char * res = calloc(START_SIZE, sizeof(char));
    while (((c = getchar()) != '\n') && (c != EOF)) {
        if (ci == cs) {
            cs *= DYN_COEF;
            tmp_chr_ptr = realloc(res, cs * sizeof(char));
            if (tmp_chr_ptr == NULL) {
                free(res);
                fprintf(stderr, "***get_str: ERROR, memory is over***\n");
                exit(1);
            }
            res = tmp_chr_ptr;
        }
        res[ci++] = (char)c;
    }
    if (ci == cs) {
        cs += 2;
        tmp_chr_ptr = realloc(res, cs * sizeof(char));
        if (tmp_chr_ptr == NULL) {
            free(res);
            fprintf(stderr, "***get_str: ERROR, memory is over***\n");
            exit(1);
        }
        res = tmp_chr_ptr;
    }
    if (c == '\n') {
        res[ci++] = '\n';
    }
    res[ci] = '\0';
    return res;
}
*/

void print_token(struct token tok) {
    printf("token type: %d\n", tok.type);
    printf("token name: %s\n", tok.name);
}


struct token_arr * make_token_array(char * str) {
    struct token_arr * res = malloc(sizeof(struct token_arr));
    struct token* res_arr = calloc(START_SIZE, sizeof(struct token));
    struct token* tmpp;
    int ci = 0;
    int cs = START_SIZE;
    while (!get_token(str, 0, &res_arr[ci]) && (res_arr[ci].type != EOL)) {
        if (ci == cs - 1) {
            cs *= DYN_COEF;
            tmpp = realloc(res_arr, cs * sizeof(struct token));
            if (tmpp == NULL) {
                free(res);
                free(res_arr);
                fprintf(stderr, "***make_token_array: memory is over***\n");
                exit(1);
            }
            res_arr = tmpp;
        }
        ci++;
    }
    res -> ul_size = ci;
    res -> al_size = cs;
    res -> arr = res_arr;
    return res;
}

void destroy_token_array(struct token_arr * tks) {
    for (int i = 0; i <= tks -> ul_size; i++) {
        free(tks -> arr[i].name);
    }
    free(tks -> arr);
    free(tks);
}