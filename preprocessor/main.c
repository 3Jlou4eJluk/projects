#include <stdio.h>
#include <string.h>
#include "preprocessor.h"

char best_string[MAX_LEN];


int main(void) {
    int c = getchar();
    int cycle_flag = 0;
    unsigned int cur_sym = 0;

    while (c != EOF) {
        if (c == '\n') {

            // если попали сюда, значит приняли очередную строку
            best_string[cur_sym] = '\0';
            cycle_flag = sub_cycle(best_string);
            while (cycle_flag) {
                cycle_flag = sub_cycle(best_string);
            }
            cur_sym = 0;
        } else {
            best_string[cur_sym] = c;
            cur_sym++;
        }
        c = getchar();
    }

    // начинаем обработку EOF
    best_string[cur_sym] = '\0';
    cycle_flag = sub_cycle(best_string);
    while (cycle_flag) {
        cycle_flag = sub_cycle(best_string);
    }
    // заканчиваем обработку EOF


}