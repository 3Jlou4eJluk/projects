#include <iostream>
#include <stdexcept>
#include <cmath>
#include <fstream>

// не больше 8 и не меньше 4
#define FOUR_RUSSIANS_CONSTANT 6
#define BLOCK_SIZE 32

class Bit_Ptr {

public:
    Bit_Ptr(uint64_t&, size_t = 0);
    Bit_Ptr& operator=(bool);
    bool operator[](size_t);
    bool operator*();

private:
    uint64_t& _word;
    size_t _bit_pos;
};


Bit_Ptr::Bit_Ptr(uint64_t& word, size_t bit_pos)
    : _word(word)
    , _bit_pos(bit_pos % 64)
{}

Bit_Ptr& Bit_Ptr::operator=(bool bit) {
    uint64_t mask = 1;
    mask = mask << (63 - _bit_pos % 64);
    _word = _word & ~mask;
    if (bit) {
        _word = _word | mask;
    }
    return *this;
}

bool Bit_Ptr::operator[](size_t pos) {
    uint64_t mask = 1;
    mask = mask << (63 - pos % 64);
    return static_cast<bool>(_word & mask);
}

bool Bit_Ptr::operator*() {
    return (*this)[_bit_pos];
}



class Bitpacked_Boolean_Matrix {

public:
    Bitpacked_Boolean_Matrix();
    Bitpacked_Boolean_Matrix(size_t m, size_t n);
    Bitpacked_Boolean_Matrix(const Bitpacked_Boolean_Matrix&) = delete;
    Bitpacked_Boolean_Matrix(size_t m, size_t n, std::istream&);
    ~Bitpacked_Boolean_Matrix();

    Bitpacked_Boolean_Matrix& operator=(const Bitpacked_Boolean_Matrix&) const = delete;
    Bit_Ptr operator[](size_t);

    size_t getm() const;
    size_t getn() const;

    friend void FourRussiansMethod(Bitpacked_Boolean_Matrix&, Bitpacked_Boolean_Matrix&, 
            Bitpacked_Boolean_Matrix&);
    friend std::ostream& operator<<(std::ostream&, Bitpacked_Boolean_Matrix&);

private:
    size_t _m_size, _n_size;

    // uint64_t quantity
    size_t _mem_size;

    uint64_t* _mem_ptr;
};

size_t Bitpacked_Boolean_Matrix::getm() const {
    return _m_size;
}

size_t Bitpacked_Boolean_Matrix::getn() const {
    return _n_size;
}


Bit_Ptr Bitpacked_Boolean_Matrix::operator[](size_t elem_pos) {
    if (elem_pos >= _m_size * _n_size) { 
        throw std::runtime_error("!ERROR!: Bitpacked_Boolean_matrix::operator[]: out of bounds");
    }

    // compute uint64_t position
    uint64_t* block_ptr = &_mem_ptr[elem_pos / 64];
    

    return Bit_Ptr(*block_ptr, elem_pos % 64);
}


Bitpacked_Boolean_Matrix::Bitpacked_Boolean_Matrix(size_t m, size_t n)
    : _m_size(m)
    , _n_size(n)
    , _mem_size(0)
    , _mem_ptr(nullptr)
{
    if (_m_size * _n_size % 64 != 0) {
        _mem_size = _m_size * _n_size / 64 * sizeof(uint64_t) + 1;
    } else {
        _mem_size = _m_size * _n_size / 64 * sizeof(uint64_t);
    }

    _mem_ptr = new uint64_t [_mem_size];
}


Bitpacked_Boolean_Matrix::Bitpacked_Boolean_Matrix(size_t m, size_t n, std::istream& input_stream)
    : _m_size(m)
    , _n_size(n)
    , _mem_size(0)
    , _mem_ptr(nullptr)
{
    if (_m_size * _n_size % 64 != 0) {
        _mem_size = _m_size * _n_size / 64 + 1;
    } else {
        _mem_size = _m_size * _n_size / 64;
    }

    _mem_ptr = new uint64_t [_mem_size];

    for (size_t  i = 0; i < _mem_size; i++) {
        _mem_ptr[i] = 0;
    }

    for (size_t i = 0; i < m * n; i++) {
        int tmp;
        input_stream >> tmp;
        uint64_t mask = 1;
        if (tmp) {
            mask = mask << (63 - i % 64);
        } else {
            mask = 0;
        }
        _mem_ptr[i / 64] = _mem_ptr[i / 64] | mask;
        //std::cout << _mem_ptr[i / 64];
    }
}


Bitpacked_Boolean_Matrix::~Bitpacked_Boolean_Matrix() {
    delete [] _mem_ptr;
}


std::ostream& operator<<(std::ostream& stream, Bitpacked_Boolean_Matrix& matrix) {
    size_t m = matrix.getm();
    size_t n = matrix.getn();
    for (size_t i = 0; i < m; i++) {
        for (size_t j = 0; j < n; j++) {
            stream << (*matrix[i * m + j] ? "1" : "0") << (j < n - 1 ? " " : "\n");
        }
    }
    return stream;
}



class Mul_Block {
public:
    Mul_Block(Bitpacked_Boolean_Matrix&, size_t ic, size_t jc);
    Mul_Block(size_t, size_t);

    size_t get_rbound() const;
    size_t get_dbound() const;

    friend std::ostream& operator<<(std::ostream&, Mul_Block&);

    void drop_block(Bitpacked_Boolean_Matrix&, size_t, size_t) const;

    friend void mul_blocks(Bitpacked_Boolean_Matrix&, size_t ic, size_t jc, Mul_Block&, Mul_Block&, uint8_t*);
    friend int main();

private:
    size_t _rbound, _dbound;
    uint8_t _data[BLOCK_SIZE][BLOCK_SIZE];
};

size_t Mul_Block::get_rbound() const {
    return _rbound;
}

size_t Mul_Block::get_dbound() const {
    return _dbound;
}


Mul_Block::Mul_Block(size_t rb, size_t db) 
    : _rbound(rb)
    , _dbound(db)
{
    for (size_t i = 0; i < BLOCK_SIZE; i++) {
        for (size_t j = 0; j < BLOCK_SIZE; j++) {
            _data[i][j] = 0;
        }
    }
}

Mul_Block::Mul_Block(Bitpacked_Boolean_Matrix& matrix, size_t ic, size_t jc)
    : _rbound(0)
    , _dbound(0)
{
    //std::cout << "-----------------------------------------------" << std::endl;
    //std::cout << "Creating block of position " << ic << " " << jc << std::endl;
    size_t m = matrix.getm();
    size_t n = matrix.getn();
    _rbound = (n - jc < BLOCK_SIZE ? n - jc : BLOCK_SIZE);
    _dbound = (m - ic < BLOCK_SIZE ? m - ic : BLOCK_SIZE);
    for (size_t j = jc; j < jc + _rbound; j++) {
        for (size_t i = ic; i < ic + _dbound; i++) {
            _data[i - ic][j - jc] = *matrix[i * n + j];
        }
    }
    //std::cout << *this;
    //std::cout << "Block creation finished-------------------------" << std::endl;
}

std::ostream& operator<<(std::ostream& stream, Mul_Block& block) {
    for (size_t i = 0; i < block._rbound; i++) {
        for (size_t j = 0; j < block._dbound; j++) {
            std::cout << static_cast<int>(block._data[i][j]) << " ";
        }
        stream << std::endl;
    }
    return stream;
}

void Mul_Block::drop_block(Bitpacked_Boolean_Matrix& to_matrix, size_t ic, size_t jc) const {
    size_t m = to_matrix.getm();

    for (size_t i = 0; i < _dbound; i++) {
        for (size_t j = 0; j < _rbound; j++) {
            to_matrix[(i + ic) * m + j + jc] = static_cast<bool>(_data[i][j]);
        }
    }
}


void mul_blocks(Bitpacked_Boolean_Matrix& matrix, size_t ic, size_t jc, Mul_Block& block_B, 
        Mul_Block& block_C, uint8_t* mul_table) {

    size_t two_pow_k = static_cast<size_t>(pow(2, FOUR_RUSSIANS_CONSTANT));
    size_t m = matrix.getm();
    size_t n = matrix.getn();

    // block bounds for first matrix
    size_t rb = (n - jc < BLOCK_SIZE ? n - jc : BLOCK_SIZE);
    size_t db = (m - ic < BLOCK_SIZE ? m - ic : BLOCK_SIZE);

    // blocks multiplication
    // size changing: (db x rb) * (rb x block_B._rbound)
    block_C._dbound = db;
    block_C._rbound = block_B._rbound;
    for (size_t i = 0; i < db; i++) {
        for (size_t j = 0; j < block_B._rbound; j++) {
            for (size_t k = 0; k < rb / FOUR_RUSSIANS_CONSTANT; k++) {
                size_t arg1 = 0, arg2 = 0;
                for (size_t l = 0; l < FOUR_RUSSIANS_CONSTANT; l++) {
                    arg1 *= 2; arg1 += *matrix[(i + ic) * n + k * FOUR_RUSSIANS_CONSTANT + l + jc];
                    arg2 *= 2; arg2 += block_B._data[k * FOUR_RUSSIANS_CONSTANT + l][j];
                }
                block_C._data[i][j] += mul_table[arg1 * two_pow_k + arg2];
            }

            // lets take into account remainder
            size_t arg1 = 0, arg2 = 0;
            for (size_t k = rb / FOUR_RUSSIANS_CONSTANT * FOUR_RUSSIANS_CONSTANT; k < rb; k++) {
                arg1 *= 2; arg1 += *matrix[(i + ic) * n + k + jc];
                arg2 *= 2; arg2 += block_B._data[k][j];
            }
            
            // now we should make the length of variables arg1 and arg2 equal to FOUR_RUSSIANS_CONSTANT
            // we have already taken a part from the extreme piece of the matrix
            size_t end = FOUR_RUSSIANS_CONSTANT - (rb - rb / FOUR_RUSSIANS_CONSTANT * FOUR_RUSSIANS_CONSTANT);
            for (size_t k = 0; k < end; k++) {
                arg1 *= 2; arg2 *= 2;
            }

            // lets apppend last part to the sum
            block_C._data[i][j] += mul_table[arg1 * two_pow_k + arg2];
            block_C._data[i][j] %= 2;
        }
    }
}


size_t scalar_multiply(size_t n1, size_t n2) {
    size_t res = 0;
    size_t tmp = n1 & n2;
    while(tmp != 0) {
        res += tmp & 1;
        tmp = tmp >> 1;
    }
    return res;
}



void FourRussiansMethod(Bitpacked_Boolean_Matrix& matrix1, Bitpacked_Boolean_Matrix& matrix2, 
        Bitpacked_Boolean_Matrix& res_matrix) {

    size_t m1 = matrix1.getm();
    size_t n1 = matrix1.getn();
    size_t m2 = matrix2.getm();
    size_t n2 = matrix2.getn();

    if (n1 != m2) {
        throw std::runtime_error("!ERROR!: void FourRussiansMethod(...): Matrix shapes are not correct\n");
    }

    size_t two_pow_k = static_cast<size_t>(pow(2, FOUR_RUSSIANS_CONSTANT));

    // mul table generation
    uint8_t* mul_table = new uint8_t [two_pow_k * two_pow_k];
    for (size_t i = 0; i < two_pow_k; i++) {
        for (size_t j = i; j < two_pow_k; j++) {
            mul_table[i * two_pow_k + j] = scalar_multiply(i, j);
            mul_table[j * two_pow_k + i] = mul_table[i * two_pow_k + j];
        }
    }

    // multiplication
    for (size_t i = 0; i < m1; i += BLOCK_SIZE) {
        for (size_t j = 0; j < n2; j+= BLOCK_SIZE) {
            Mul_Block matrix3_block(res_matrix, i, j);
            for (size_t k = 0; k < n1; k += BLOCK_SIZE) {
                Mul_Block matrix2_block(matrix2, k, j);
                mul_blocks(matrix1, i, k, matrix2_block, matrix3_block, mul_table);
            }
            matrix3_block.drop_block(res_matrix, i, j);
            
            //std::cout << "res_block: " << std::endl;
            //std::cout << matrix3_block;
        }
    }
    delete [] mul_table;

}





int main() {
    size_t m, n, k;
    std::cin >> m >> n >> k;
    Bitpacked_Boolean_Matrix matrix1(m, n, std::cin);
    Bitpacked_Boolean_Matrix matrix2(n, k, std::cin);
    Bitpacked_Boolean_Matrix mul_res(m, k);

    std::ofstream runtime_info_stream;
    runtime_info_stream.open("./runtime_info.txt", std::ios::app);

    unsigned long long start_time = clock();
    FourRussiansMethod(matrix1, matrix2, mul_res);
    unsigned long long end_time = clock();



    runtime_info_stream << "Function_ tuntime: " << (end_time - start_time) / CLOCKS_PER_SEC << std::endl;

    std::ofstream res_file_stream;
    res_file_stream.open((std::string("./cpp_mul_matrix_result") + "_" + std::to_string(m) + "_" + std::to_string(n) + "_" + std::to_string(k) + ".txt").c_str());
    
    if (!res_file_stream.is_open()) {
        throw std::runtime_error("!ERROR!: file couldn't be open");
    }

    // let's write result matrix in file
    res_file_stream << mul_res;
    return 0;
}