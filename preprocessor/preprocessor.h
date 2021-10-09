
enum {
    INP_LEN = 82, 
    VAR_LEN = 33,
    MAX_LEN = 10002,
    VAL_LEN = 82,
    VAR_Q = 32
};

char *search_dollar(char *s, unsigned int *p_in_names);
unsigned int proc_def(char *s);
unsigned int sub_cycle(char *s);