#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/wait.h>
#include "tokens.h"
#include "descent.h"
#include "run.h"


int run_sngl_cmd(struct Node * node) {
    int fres = 0;
    int stat;
    if (!(fres = fork())) {
        int file;
        if (node -> ifile != NULL) {
            file = open(node -> ifile, O_RDONLY);
            if (file == -1) {
                fprintf(stderr, "Ошибка открытия файла на чтение\n");
                exit(1);
            }
            dup2(file, 0);
            close(file);
        }
        if (node -> ofile != NULL) {
            switch(node -> te_flag) {
                case 1:
                    file = open(node -> ofile, O_WRONLY | O_CREAT | O_APPEND, 0666);
                    break;
                default:
                    file = open(node -> ofile, O_WRONLY | O_CREAT | O_TRUNC, 0666);
                    break;
            }
            if (file == -1) {
                fprintf(stderr, "Ошибка открытия файла на запись\n");
                exit(1);
            }
            dup2(file, 1);
            close(file);
        }
        execvp(*(node -> argv), node -> argv);
        exit(127);
    } else if (fres < 0) {
        return 127;
    }
    waitpid(fres, &stat, 0);
    if (WIFEXITED(stat)) {
        return WEXITSTATUS(stat);
    }
    if (WIFSIGNALED(stat)) {
        return 128 + WTERMSIG(stat);
    }
    return 0;
}

int run_pipes(struct Node * node) {
    struct Node * cnode = node;
    int fst_flg = 2;
    int fdo[2];
    int fd[2];
    int fres;
    while (cnode != NULL) {
        if (!fst_flg) {
            close(fdo[0]);
            close(fdo[1]);
        }
        fdo[0] = fd[0];
        fdo[1] = fd[1];
        pipe(fd);
        if (!(fres = fork())) {
            if (!fst_flg || (fst_flg == 1)) {
                dup2(fdo[0], 0);
                close(fdo[0]);
                close(fdo[1]);
            }
            if (cnode -> pipe != NULL) {
                dup2(fd[1], 1);
            }
            close(fd[1]);
            close(fd[0]);
            int file;
            if (cnode -> ifile != NULL) {
                file = open(cnode -> ifile, O_RDONLY);
                if (file == -1) {
                    fprintf(stderr, "Ошибка открытия файла на чтение\n");
                    exit(1);
                }
                dup2(file, 0);
                close(file);
            }
            if (cnode -> ofile != NULL) {
                switch(cnode -> te_flag) {
                    case 1:
                        file = open(cnode -> ofile, O_WRONLY | O_CREAT | O_APPEND, 0666);
                        break;
                    case 0:
                        file = open(cnode -> ofile, O_WRONLY | O_CREAT | O_TRUNC, 0666);
                        break;
                    default:
                        break;
                }
                if (file == -1) {
                    fprintf(stderr, "Ошибка открытия файла на запись\n");
                    exit(1);
                }
                dup2(file, 1);
                close(file);
            }
            if (cnode -> br_p == NULL) {
                execvp(*(cnode -> argv), cnode -> argv);
                exit(127);
            }
            exit(run_tree(cnode -> br_p));
        } else if (fres < 0) {
            return 127;
        }
        if (fst_flg > 0) {
            fst_flg--;
        }
        cnode = cnode -> pipe;
    }
    if (!fst_flg) {
        close(fdo[0]);
        close(fdo[1]);
    }
    if (!fst_flg ||(fst_flg == 1)) {
        close(fd[0]);
        close(fd[1]);
    }
    int stat;
    waitpid(fres, &stat, 0);
    int last_status = 0;
    if (WIFEXITED(stat)) {
        last_status = WEXITSTATUS(stat);
    } else if (WIFSIGNALED(stat)) {
        last_status = 128 + WTERMSIG(stat);
    }

    while (wait(NULL) > 0);
    return last_status;
}


int run_tree(struct Node * node) {
    int code = 0;
    int fres;
    if (!node -> bg_flag) {
        if (node -> pipe == NULL) {
            if (node -> br_p == NULL) {
                code = run_sngl_cmd(node);
                if (node -> next == NULL) {
                    return code;
                }
                if (!node -> op_code) {
                    return run_tree(node -> next);
                }
                if (code == 1) {
                    return code;
                }
                return run_tree(node -> next);
            }
            code = run_tree(node -> br_p);
            if (node -> next == NULL) {
                return code;
            }
            if (!node -> op_code) {
                return run_tree(node -> next);
            }
            if (code == 1) {
                return code;
            }
            return run_tree(node -> next);
        }
        code = run_pipes(node);
        if (node -> next == NULL) {
            return code;
        }
        if (!node -> op_code) {
            return run_tree(node -> next);
        }
        if (code == 1) {
            return code;
        }
        return run_tree(node -> next);
    }
    struct Node * tmp_next = node -> next;
    node -> next = NULL;
    if (!(fres = fork())) {
        node -> bg_flag = 0;
        exit(run_tree(node));
    }
    node -> next = tmp_next;
    if (node -> next != NULL) {
        code = run_tree(node -> next);
    }
    waitpid(fres, NULL, 0);
    return code;
}