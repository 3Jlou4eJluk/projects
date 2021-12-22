

enum Type {
    EOL,
    DIVIDER,
    NAME
};

enum {
    START_SIZE = 10,
    DYN_COEF = 2
};


/*
    token может быть:
    - именем команды
    - аргументом команды
    - управляющим символом
    - именем файла
*/
struct token {
    int type;
    char *name;
};

struct token_arr {
    // useful size
    int ul_size;
    // actual size
    int al_size;
    struct token * arr;
};

extern int div_check(int sym);
extern int get_token(char* str, int reload_flag, struct token * tok);
extern char* get_str(void);
extern void print_token(struct token tok);
extern struct token_arr * make_token_array(char * str);
extern void destroy_token_array(struct token_arr * tks);