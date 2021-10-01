#include <stdio.h>
#include <stdlib.h>
#include "membanks.h"


static unsigned int used = 0;
static unsigned int banks_quantity = 0;

static char data[DATA_SIZE]; 
static unsigned int data_border[DATA_SIZE];

/*
//Возвращает указатель на первый элемент блока
unsigned int start_search(unsigned int bank) {
    unsigned int block_starts = 0;
    for (int i = 0; i < bank; i++) {
        block_starts += data_border[i];
    }
    return block_starts;
}

void print_banks(void) {
    int j = 0;
    int last = 0;
    while ((j < DATA_SIZE) && (data_border[j] != 0)) {
        j++;
    }
    for (int i = 0; i < j; i++) {
        printf("Printing block: %d\n", i);
        for (int k = last; k < last + data_border[i]; k++) {
            printf("Byte #: %d Value: %u\n", k, data[k]);
        }
        last += data_border[i]; 
    }
}
*/

unsigned int alloc(unsigned int size) {
    int i = 0;
    while ((i < DATA_SIZE) && (data_border[i] != 0)) {
        i++;
    }
    if ((i >= DATA_SIZE) || (used + size > DATA_SIZE)) {
        printf("\n***alloc ERROR: data overflow***\n");
        exit(1);
    } else {
        used += size;
        banks_quantity += 1;
        data_border[i] = size;
        return i;
    }
}


void dealloc(unsigned int block_num) {
    if (block_num >= DATA_SIZE) {
        printf("\n***dealloc ERROR: invalid block_num***\n");
        exit(1);
    } else if (data_border[block_num] == 0) {
        printf("\n***dealloc ERROR: block does not exist***\n");
        exit(1);
    } else {
        unsigned int rem_block_size = data_border[block_num];
        unsigned int rem_block_starts = 0;
        for (int i = 0; i < block_num; i++) {
            rem_block_starts += data_border[i];
        }

        for (int i = 0; i < rem_block_size; i++) {
            for (int j = rem_block_starts; j < used; j++) {
                data[j] = data[j + 1];
            }
            data[used] = 0;
            used -= 1;
        }
        for (int i = block_num; i < banks_quantity; i++) {
            data_border[i] = data_border[i + 1];
        }
        data_border[banks_quantity] = 0;
        banks_quantity -= 1;
    }
}


void write_byte(unsigned int bank, unsigned int delta, char byte) {
    if (bank >= banks_quantity || bank < 0) {
        printf("\n***writebyte ERROR: bank not existing***\n");
        exit(1);
    } else {
        unsigned int block_starts = 0;
        for (int i = 0; i < bank; i++) {
            block_starts += data_border[i];
        }
        if (delta >= data_border[bank]) {
            printf("\n***writebyte ERROR: byte doesn't existing in bank***\n");
            exit(1);
        } else {
            data[block_starts + delta] = byte;
        }
    }
}


char read_byte(unsigned int bank, unsigned int delta) {
    if (bank >= banks_quantity || bank < 0) {
        printf("\n***readbyte ERROR: bank not existing***\n");
        exit(1);
    } else {
        unsigned int block_starts = 0;
        for (int i = 0; i < bank; i++) {
            block_starts += data_border[i];
        }
        if (delta >= data_border[bank]) {
            printf("\n***readbyte ERROR: byte doesn't existing in bank\n");
            exit(1);
        } else {
            return data[block_starts + delta];
        }
    }
}


unsigned int reallocm(unsigned int bank, unsigned int size) {
    if (bank >= banks_quantity) {
        printf("\n*** realloc ERROR: bank not exist, abort***\n");
        return 1;
    } else if (size > DATA_SIZE - used) {
        printf("\n***realloc ERROR: memory is over, abort***\n");
        return 1;
    } else {
        unsigned int block_starts = 0;
        for (int i = 0; i < bank; i++) {
            block_starts += data_border[i];
        }
        block_starts += data_border[bank];
        for(int i = 0; i < size - data_border[bank]; i++) {
            for (int j = used; j > block_starts; j--) {
                data[j + 1] = data[j];
            }
            used += 1;
            data[block_starts] = 0;
        }
        data_border[bank] = size;
        return 0;
    }
}


/*
unsigned int get_block_len(unsigned int block) {
    return data_border[block];
}

void print_block_string(unsigned int block) {
    if (data_border[block] == 0 || block < 0 || block >= DATA_SIZE) {
        printf("\n***printblock ERROR: block doesn't existing***\n");
    } else {
        unsigned int block_starts = 0;
        for (int i = 0; i < block; i++) {
            block_starts += data_border[i];
        }
        for (int i = 0; i < data_border[block]; i++) {
            putchar(data[block_starts + i]);
        }
        putchar('\n');
    }
}
*/
