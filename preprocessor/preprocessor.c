// входная строка и строка, которая обрабатывается функцией sub_sycle,
// не хранятся в этом модуле

#include <stdio.h>
#include <string.h>
#include "preprocessor.h"

// количество активных переменных
static unsigned int act_var = 0;

// массив имён переменных, отсортированный по убыванию длин
static char names[VAR_Q][VAR_LEN];
static char values[VAR_Q][VAL_LEN];

// массив с временным именем, используется функцией proc_def
// для проверки корректности имени и копирования имени в массив names
static char tmp_name[VAR_LEN];
static char *end_tn = tmp_name;

// сортирует одновременно массивы names и values по длине names
static void sort_them(void) {
    char tmp[VAL_LEN];
    unsigned int swaps = 0;
    do {
        swaps = 0;
        for (int i = 0; i < act_var; i++) {
            if (strlen(names[i]) < strlen(names[i + 1])) {

                memcpy(tmp, names[i], strlen(names[i]) + 1);
                memcpy(names[i], names[i + 1], strlen(names[i + 1]) + 1);
                memcpy(names[i + 1], tmp, strlen(tmp) + 1);

                memcpy(tmp, values[i], strlen(values[i]) + 1);
                memcpy(values[i], values[i + 1], strlen(values[i + 1]) + 1);
                memcpy(values[i + 1], tmp, strlen(tmp) + 1);

                swaps += 1;
            }
        }
    } while (swaps != 0);
}


// functions search's for first processable dollar
// p_in_names - номер найденной переменной 
// в names и в values
char *search_dollar(char *s, unsigned int *p_in_names) {
    char *var_pos = NULL;
    unsigned int slen = strlen(s);
    for (int i = 0; i < slen; i++) {
        if (s[i] == '$') {
            for (int j = 0; j < act_var; j++) {

                // здесь пытаемся найти переменную,
                // которая входит в строку
                var_pos = strstr(&s[i] + 1, names[j]);
                if (var_pos != NULL) {
                    *p_in_names = j;
                    return var_pos;
                }
            }
            // вышли из цикла - значит не нашли
            // ни одной переменной в строке
            return search_dollar(&s[i] + 1, p_in_names);
        }
    }
    // стало быть, доллар она не нашла...
    return NULL;
}


// проверяет и обрабатывает определение, возвращает 1 - если
// не определение, 0 - если определение
unsigned int proc_def(char *s) {
    char *eq_pos = strchr(s, '=');
    if (eq_pos == NULL) {
        return 1;
    }
    if (eq_pos - s > 0) {

        // может быть определение
        for (char *i = s; i < eq_pos; i++) {
            if (!( ((*i >= 'A') && (*i <= 'Z')) || ((*i >= 'a') && (*i <='z')) )) {

                //не забываем сбросить tmp_name перед выходом
                end_tn = tmp_name;
                // не определение, есть символы отличные от букв
                return 1;
            } else {
                *end_tn = *i;
                end_tn += 1;
            }
        }

        // вышло, значит точно определение
        *end_tn = '\0';

        for (int i = 0; i < act_var; i++) {
            if (strcmp(tmp_name, names[i]) == 0) {
                // если попали сюда, значит поймали переопределение
                strcpy(values[i], eq_pos + 1);
                end_tn = tmp_name;
                return 0;
            }
        }
        strcpy(names[act_var], tmp_name);
        strcpy(values[act_var], eq_pos + 1);

        act_var++;
        end_tn = tmp_name;
        sort_them();
        return 0;
    } else {
        return 1;
    }
}


// функция одного цикла обработки, возвращает 0, если
// обработка завершена, 1 иначе
// предполагается, что функция применяется к обрабатываемой
// строке, а не к той, в которую вводим
unsigned int sub_cycle(char *s) {
    unsigned int slen = strlen(s);
    unsigned int def_flag = 0;
    if (*s != '#') {
        unsigned int first_name = 0;
        char *first_dollar = search_dollar(s, &first_name);
        def_flag = proc_def(s);
        if (def_flag) {
            if (first_dollar == NULL) {
                def_flag = proc_def(s);
                if (def_flag) {
                    printf("%s\n", s);
                }
                return 0;
            } else {
                int delta = strlen(names[first_name]) - strlen(values[first_name]);
                if (!delta) {

                    //если длина имени равна длине значения
                    memmove(first_dollar - 1, values[first_name], 
                            strlen(values[first_name]));
                    memmove(first_dollar - 1 + strlen(names[first_name]),
                            first_dollar + strlen(names[first_name]),
                            s + slen - (first_dollar + 
                            strlen(names[first_name])) + 1);
                } else if (delta > 0) {

                    //если длина имени больше длины значения
                    memmove(first_dollar - 1, values[first_name], 
                            strlen(values[first_name]));
                    memmove(first_dollar + strlen(values[first_name]) - 1, 
                            first_dollar + strlen(names[first_name]), 
                            s + slen - (first_dollar + 
                            strlen(names[first_name])) + 1);
                } else {

                    //если длина имени меньше длины значения
                    memmove(first_dollar - 1 + strlen(values[first_name]), 
                            first_dollar + strlen(names[first_name]),
                            s + slen - (first_dollar + 
                            strlen(names[first_name])) + 1);
                    memmove(first_dollar - 1, values[first_name], 
                            strlen(values[first_name]));
                }
                if (search_dollar(s, &first_name) == NULL) {
                    if (s[0] != '#') {
                        def_flag = proc_def(s);
                        if (def_flag) {
                            printf("%s\n", s);
                        }
                    }
                    return 0;
                } else {
                    return 1;
                }
            }
        }
        return 0;
    } else {
        
        //если коммент, то ничего не делаем
        return 0;
    }

}
