#include <stdio.h>
#include <stdlib.h>
#include "membanks.h"

int main(void) {
    int maxx = 0;
    int cur_bank = 0, cur_d = 0;
    int ch = 0;
    alloc(1);
    alloc(1);
    ch = getchar();
    while (ch != EOF) {
        if (ch != '\n') {
            write_byte(1, cur_d, ch);
            reallocm(1, cur_d + 2);
            cur_d++;
        } else {
            if (cur_d > maxx) {
                maxx = cur_d;
                write_byte(1, cur_d, '\n');
                dealloc(0);
                alloc(1);
            } else {
                dealloc(1);
                alloc(1);
            }
            cur_d = 0;
        }
        ch = getchar();
    }
    if (cur_d > maxx) {
        dealloc(0);
        maxx = cur_d;
    }
    for (int i = 0; i < maxx; i++) {
        printf("%c", read_byte(0, i));
    }
    printf("\n");
    return 0;
}