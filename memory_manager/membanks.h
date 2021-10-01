enum {DATA_SIZE = 100000};
unsigned int alloc(unsigned int size);
void dealloc(unsigned int block_num);
void write_byte(unsigned int, unsigned int, char);
char read_byte(unsigned int, unsigned int);
unsigned int reallocm(unsigned int bank, unsigned int size);
//void print_block_string(unsigned int block);
//void print_banks(void);