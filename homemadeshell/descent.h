

struct Node {   
    char **argv;
    char *ifile;
    char *ofile;
    int bg_flag;
    int te_flag;
    int op_code;
    struct Node* br_p;
    struct Node* pipe;
    struct Node* next;
};

extern struct Node* shell_cmd(struct token_arr* tks, int * suc_flag);
extern int cmdl(struct token_arr* tks, struct Node* cur_node, int * cur_tok);
extern int conv(struct token_arr* tks, struct Node* cur_node, int * cur_tok);
extern int cmd(struct token_arr* tks, struct Node* cur_node, int * cur_tok);
extern int scmd(struct token_arr* tks, struct Node* cur_node, int * cur_tok);

extern void print_node(struct Node * node);
extern struct Node * node_init(void);
extern void print_tree(struct Node * node, int counter);