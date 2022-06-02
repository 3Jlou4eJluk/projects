/*
Грамматика для синтаксического анализатора
V -> AB
B -> '('C
C -> ')' | P ')'
P -> TY
Y -> ',' TY | eps
T - tree
V - vertex
P - sub tree
A - name
*/

/*
Грамматика имения для лексического анализатора
S -> LM
M -> LM | NM | eps
L - letter
N - num
*/


#include <iostream>
#include <cctype>
#include <stdexcept>
#include <sstream>

enum Token_type {
    LBRACKET,
    RBRACKET,
    COM,
    NAME,
    END
};

struct Token {
    Token();
    Token_type type;
    std::string name;
};

Token::Token()
    : type(END)
    , name("")
{}


class LexA {
    public:
        LexA(LexA&) = delete;
        LexA& operator=(LexA&) = delete;
        LexA();
        Token get_next_token(std::istream& parse_stream);
        void reload();
        Token get_cur_token() const;
    private:
        // funcs
        void next();
        // считывает имя, засовывает в cur_tok
        void name();
        void S();
        void L();
        void N();
        void M();

        //data
        std::istream * parse_stream_ptr;
        int cur_sym;
        Token cur_tok;
        bool init_flag;
};

void LexA::reload() {
    init_flag = false;
}

Token LexA::get_cur_token() const {
    return cur_tok;
}

LexA::LexA()
    : parse_stream_ptr(nullptr)
    , cur_sym(255)
    , cur_tok()
    , init_flag(false)
{}

Token LexA::get_next_token(std::istream& parse_stream) {
    if (!init_flag) {
        parse_stream_ptr = &parse_stream;
        next();
        init_flag = true;
    }
    while (isspace(cur_sym)) {
        next();
    }
    if (cur_sym == -1) {
        cur_tok.type = END;
        cur_tok.name = "";
        return cur_tok;
    } else if (cur_sym == static_cast<int>('(')) {
        cur_tok.type = LBRACKET;
        cur_tok.name = "(";
        next();
        return cur_tok;
    } else if (cur_sym == static_cast<int>(')')) {
        cur_tok.type = RBRACKET;
        cur_tok.name = ")";
        next();
        return cur_tok;
    } else if (cur_sym == static_cast<int>(',')) {
        cur_tok.type = COM;
        cur_tok.name = ",";
        next();
        return cur_tok;
    } else if (isalpha(cur_sym)) {
        name();
        return cur_tok;
    } else {
        throw std::runtime_error("Unexpected symbol");
    }
}

void LexA::name() {
    cur_tok.type = NAME;
    cur_tok.name = "";
    S();
}

void LexA::S() {
    L();
    M();
}

void LexA::M() {
    if (isalpha(cur_sym)) {
        L();
        M();
    } else if (isdigit(cur_sym)) {
        N();
        M();
    }
}

void LexA::L() {
    if (isalpha(cur_sym)) {
        cur_tok.name += static_cast<char>(cur_sym);
        next();
        return;
    }
}

void LexA::N() {
    if (isdigit(cur_sym)) {
        cur_tok.name += static_cast<char>(cur_sym);
        next();
        return;
    }
}

void LexA::next() {
    cur_sym = parse_stream_ptr -> get();
}


class Parser {
    public:
        Parser();
        void parse(const std::string&);
        void parse_s(std::istream&);
        Parser(Parser&) = delete;
        Parser& operator=(Parser&) = delete;
    private:

        // funcs
        void V();
        void A();
        void B();
        void C();
        void P();
        void Y();

        // data
        std::istream* parse_stream_ptr;
        LexA analyser;
};

void Parser::parse(const std::string& parse_string) {
    std::stringstream parse_stream_tmp(parse_string);
    parse_s(parse_stream_tmp);
}

Parser::Parser()
    : parse_stream_ptr(nullptr)
    , analyser()
{}

void Parser::parse_s(std::istream& parse_stream) {
    parse_stream_ptr = &parse_stream;
    analyser.reload();
    analyser.get_next_token(parse_stream);
    V();
    if (analyser.get_cur_token().type != END) {
        throw std::runtime_error("Parse error");
    }
}

void Parser::V() {
    A();
    B();
}

void Parser::A() {
    if (analyser.get_cur_token().type != NAME) {
        throw std::runtime_error("Name expected, but nof found");
    }
    analyser.get_next_token(*parse_stream_ptr);
}

void Parser::B() {
    if (analyser.get_cur_token().type != LBRACKET) {
        throw std::runtime_error("LBRACKET expected");
    }
    analyser.get_next_token(*parse_stream_ptr);
    C();
}

void Parser::C() {
    if (analyser.get_cur_token().type == RBRACKET) {
        analyser.get_next_token(*parse_stream_ptr);
    } else if (analyser.get_cur_token().type == NAME) {
        P();
        if (analyser.get_cur_token().type != RBRACKET) {
            throw std::runtime_error("RBRACKET expected");
        }
        analyser.get_next_token(*parse_stream_ptr);
    } else {
        throw std::runtime_error("RBRACKET expected");
    }
}

void Parser::P() {
    V();
    Y();
}

void Parser::Y() {
    if (analyser.get_cur_token().type == COM) {
        analyser.get_next_token(*parse_stream_ptr);
        V();
        Y();
    }
}

int main() {
    Parser my_parser;
    try {
        my_parser.parse_s(std::cin);
    } catch(std::runtime_error& err) {
        std::cout << err.what() << std::endl;
    }
    return 0;
}