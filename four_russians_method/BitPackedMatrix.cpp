#include <iostream>
#include <cstdlib>
#include <cstdio>
#include "BitPackedMatrix.hpp"

BitPackedMatrix::BitPackedMatrix()
        : _data_ptr(nullptr)
        , _allocated_mem_value(0)
        , _vertical_size(0)
        , _horizontal_size(0)
        , _system_horizontal_size(0)
        , _blocks_per_row(0)
{
}

BitPackedMatrix::BitPackedMatrix(const size_t vsize, const size_t hsize)
        : _data_ptr(nullptr)
        , _allocated_mem_value(0)
        , _vertical_size(vsize)
        , _horizontal_size(hsize)
        , _system_horizontal_size(hsize)
        , _blocks_per_row(0)
{
    if (_system_horizontal_size % 64) {
        _system_horizontal_size = _horizontal_size + 64 - _system_horizontal_size % 64;
    }

    _blocks_per_row = (_system_horizontal_size + 64 - 1) / 64;

    _allocated_mem_value = _vertical_size * _system_horizontal_size / 64  + 1;

    _data_ptr = static_cast<uint64_t*> (malloc(_allocated_mem_value * sizeof(uint64_t)));
}

BitPackedMatrix::BitPackedMatrix(const size_t vsize, const size_t hsize, std::istream & stream)
        : _data_ptr(nullptr)
        , _allocated_mem_value(0)
        , _vertical_size(vsize)
        , _horizontal_size(hsize)
        , _system_horizontal_size(hsize)
        , _blocks_per_row(0)
{
    if (_horizontal_size % 64) {
        _system_horizontal_size = _horizontal_size + 64 - _horizontal_size % 64;
    }

    _blocks_per_row = (_system_horizontal_size + 64 - 1) / 64;

    _allocated_mem_value = _vertical_size  * _system_horizontal_size / 64 + 1;

    _data_ptr = static_cast<uint64_t*> (malloc(_allocated_mem_value * sizeof(uint64_t)));

    int inp = 0;
    uint64_t current_bit_position = 0;
    size_t current_block_position = 0;  // current uint64_t
    uint64_t current_block = 0;
    for (size_t i = 0; i < _vertical_size; i++) {
        for (size_t j = 0; j < _system_horizontal_size; j++) {
            if (current_bit_position > 63 || j >=_horizontal_size) {
                _data_ptr[current_block_position] = current_block;
                current_block = 0;
                current_bit_position = 0;
                current_block_position += 1;
                if (j >= _horizontal_size) {
                    break;
                }
            }
            stream >> inp;
            //std::cout << "Считали: " << inp << std::endl;
            current_block |= (static_cast<uint64_t>(inp ? 1 : 0) << current_bit_position);
            current_bit_position += 1;
        }
    }
    if (current_block != 0) {
        _data_ptr[current_block_position] = current_block;
    }
}

/*
// This constructor is not ready to use!!!
BitPackedMatrix::BitPackedMatrix(BitPackedMatrix &from_matrix, size_t ax0_start, size_t ax1_start, size_t vsize,
                                 size_t hsize)
    : _data_ptr(nullptr)
    , _allocated_mem_value(0)
    , _vertical_size(vsize)
    , _horizontal_size(hsize)
    , _system_horizontal_size(hsize)
    , _blocks_per_row(0)
{
    if (_horizontal_size % 64) {
        _system_horizontal_size = _horizontal_size + 64 - _horizontal_size % 64;
    }

    _blocks_per_row = (_system_horizontal_size + 64 - 1) / 64;

    _allocated_mem_value = _vertical_size  * _system_horizontal_size / 64 + 1;

    _data_ptr = static_cast<uint64_t*> (malloc(_allocated_mem_value * sizeof(uint64_t)));

    this->fill_with_zeros();

#define BIT_SHIFT (ax1_start % 64)
#define UINT_START (ax1_start / 64)
    uint8_t bit_pos = BIT_SHIFT;
    uint64_t mask = 0;
    uint64_t skip_mask = 0;
    uint64_t elapsed_bits_quantity = hsize;
    for (size_t j = 0; j < _blocks_per_row; j++) {
        skip_mask = build_filled_mask(bit_pos);
        mask = ~skip_mask & build_filled_mask(bit_pos + elapsed_bits_quantity);

        for (size_t i = 0; i < _vertical_size; i++) {
            _data_ptr[i * _blocks_per_row + j] =
                    (from_matrix._data_ptr[(ax0_start + i) * from_matrix._blocks_per_row + UINT_START + j] & mask) >> bit_pos;

             // Теперь надо достать кусок следующего uint64_t. Его длина составляет bit_pos
            if (j + 1 + UINT_START < from_matrix._blocks_per_row) {
                _data_ptr[i * _blocks_per_row + j] ^= \
                from_matrix._data_ptr[(ax0_start + i) * from_matrix._blocks_per_row + UINT_START + j + 1] & skip_mask << 64 - bit_pos;
            }
        }
        elapsed_bits_quantity -= (elapsed_bits_quantity < 64 - bit_pos ? elapsed_bits_quantity : 64 - bit_pos);
    }
#undef BIT_SHIFT
#undef UINT_START
}
*/


BitPackedMatrix::~BitPackedMatrix() {
    free(_data_ptr);
}


std::ostream& operator<<(std::ostream& stream, const BitPackedMatrix& matrix) {

#define BLOCK_NUMBER (j / 64)

    uint64_t mask = 0;
    uint8_t bit_number = 0;
    uint8_t bit = 0;


    for (size_t i = 0; i < matrix._vertical_size; i++) {

        //std::printf("%03d ", static_cast<int>(i));

        for (size_t j = 0; j < matrix._system_horizontal_size; j++) {
            if (j >= matrix._horizontal_size) {
                break;
            }

            bit_number = j % 64;
            mask = static_cast<uint64_t>(1) << bit_number;
            bit = (matrix._data_ptr[i * matrix._blocks_per_row + BLOCK_NUMBER] & mask ? 1 : 0);
            stream << static_cast<uint64_t>(bit ? 1 : 0) << (j < matrix._horizontal_size - 1 ? " " : "\n");
        }
    }
    return stream;
#undef BLOCK_NUMBER
}

void BitPackedMatrix::xor_to_row(size_t to_row, size_t from_row, const BitPackedMatrix & from_matrix) {
    if (_system_horizontal_size != from_matrix._system_horizontal_size) {
        throw std::runtime_error("***BitPackedMatrix::xor_to_row: Rows have different lengths***");
    }

    for (size_t i = 0; i < from_matrix._blocks_per_row; i++) {
        _data_ptr[to_row * from_matrix._blocks_per_row + i] ^=
                from_matrix._data_ptr[from_row * from_matrix._blocks_per_row + i];
    }
}

void BitPackedMatrix::row_to_zeros(size_t line_number) {
    for (size_t i = 0; i < _blocks_per_row; i++) {
        _data_ptr[_blocks_per_row * line_number + i] = 0;
    }
}

void BitPackedMatrix::fill_with_zeros() {
    for (size_t i = 0; i < _vertical_size; i++) {
        this ->row_to_zeros(i);
    }
}

void BitPackedMatrix::set_row_value(size_t to_row, size_t from_row, const BitPackedMatrix& from_matrix) {
    for (size_t i = 0; i < _blocks_per_row; i++) {
        _data_ptr[to_row * _blocks_per_row + i] = from_matrix._data_ptr[from_row * _blocks_per_row + i];
    }
}


BitPackedMatrix::Row::Row(size_t row_num, BitPackedMatrix & from_matrix, bool allocate_mem_flag=false)
        : _row_num(row_num)
        , _allocated_mem_flag(allocate_mem_flag)
        , _from_matrix_object(from_matrix)
        , _row_storage(nullptr)
        , _row_start(nullptr)
{
    if (_row_num >= from_matrix._vertical_size) {
        throw std::runtime_error("***BitpackedMatrix::Row::Row: Error! Rows len's are different***");
    }

    if (_allocated_mem_flag) {
        _row_storage = new BitPackedMatrix(1, from_matrix._horizontal_size);
        _row_start = _row_storage->_data_ptr;

        _row_storage->set_row_value(0, _row_num, from_matrix);
        return;
    }
    _row_start = from_matrix._data_ptr + from_matrix._blocks_per_row * _row_num;
}

BitPackedMatrix::Row::~Row() {
    if (_allocated_mem_flag) {
        delete _row_storage;
    }
}

BitPackedMatrix::Row &BitPackedMatrix::Row::operator^(const BitPackedMatrix::Row &oth) {
    if (_from_matrix_object._blocks_per_row != oth._from_matrix_object._blocks_per_row) {
        throw std::runtime_error("***BitPackedMatrix::Row::operator^: Error! Rows sizes are not compatible.***");
    }
    for (size_t i = 0; i < _from_matrix_object._blocks_per_row; i++) {
        _row_start[i] ^= oth._row_start[i];
    }
    return *this;
}

BitPackedMatrix::Row &BitPackedMatrix::Row::operator=(const BitPackedMatrix::Row &oth) {
    if (&oth == this) {
        return *this;
    }
    if (_from_matrix_object._blocks_per_row != oth._from_matrix_object._blocks_per_row) {
        throw std::runtime_error("***BitPackedMatrix::Row::operator=: Error! Rows sizes are not compatible.***");
    }
    for (size_t i = 0; i < _from_matrix_object._blocks_per_row; i++) {
        _row_start[i] = oth._row_start[i];
    }
    return *this;
}

BitPackedMatrix::Row BitPackedMatrix::get_row(size_t line) {
    return {line, *this};
}


uint64_t* RowFromBottom(const BitPackedMatrix& matrix, size_t block_number, size_t num_from_end, size_t k) {
#define NEEDED_ROW_NUMBER ((block_number + 1) * k - num_from_end)
    if (NEEDED_ROW_NUMBER >= matrix._vertical_size) {
        return nullptr;
    }
    return matrix._data_ptr + (NEEDED_ROW_NUMBER) * matrix._blocks_per_row;
#undef NEEDED_ROW_NUMBER
}


inline size_t two_pow(size_t pow) {
    return static_cast<size_t>(1) << pow;
}

size_t build_filled_mask(size_t k) {
    if (k >= 64) {
        return (((static_cast<size_t>(1) << 63) - 1) | (static_cast<size_t>(1) << 63));
    }
    return (static_cast<size_t>(1) << k) - 1;
}


size_t rotate_uint(size_t uint_to_rotate, size_t k) {
    size_t res = 0;
    for (size_t i = 0; i < k; i++) {
        res = res << 1;
        res |= uint_to_rotate % 2;
        uint_to_rotate = uint_to_rotate >> 1;
    }
    return res;
}

size_t rotate_whole_uint(size_t uint_to_rotate) {
    size_t res = 0;
    while(uint_to_rotate) {
        res = res << 1;
        res |= uint_to_rotate % 2;
        uint_to_rotate = uint_to_rotate >> 1;
    }
    return res;
}


size_t compute_index(const BitPackedMatrix& matrix, size_t matrix_block_num, size_t k, size_t row_num) {
    size_t res = 0,
            len_res = 0,
            current_uint_index = row_num * matrix._blocks_per_row + matrix_block_num * k / 64,
            current_uint = 0,
            current_bit_in_uint = matrix_block_num * k % 64,
            left_bits = k,
            mask = 0,
            zeros_on_the_right = 0;
#define CURRENT_UINT_AVAILABLE_BITS (64 - current_bit_in_uint)
    while (left_bits) {
        if (matrix_block_num * k < matrix._system_horizontal_size) {
            current_uint = matrix._data_ptr[current_uint_index];
        } else {
            current_uint = 0;
        }
        if (left_bits <= CURRENT_UINT_AVAILABLE_BITS) {
            mask = build_filled_mask(current_bit_in_uint + left_bits) & (~build_filled_mask(current_bit_in_uint));
            zeros_on_the_right = current_bit_in_uint;
            res |= ((mask & current_uint) >> zeros_on_the_right) << len_res;
            left_bits = 0;
            break;
        }
        mask = build_filled_mask(64) & ~build_filled_mask(current_bit_in_uint);
        zeros_on_the_right = current_bit_in_uint;
        res |= ((mask & current_uint) >> zeros_on_the_right) << len_res;
        len_res += CURRENT_UINT_AVAILABLE_BITS;
        left_bits -= CURRENT_UINT_AVAILABLE_BITS;
        current_bit_in_uint = 0;
        current_uint_index += 1;
    }
#undef CURRENT_UINT_AVAILABLE_BITS
    return rotate_uint(res, k);
}



/*
 * Attention! res_matrix should be zero intialized!
 */
void FourRussiansMethod(const BitPackedMatrix& matrix1, const BitPackedMatrix& matrix2, BitPackedMatrix& res_matrix,
                        size_t k) {
    // Let's check matrix's shapes compatibility
    if (matrix1._vertical_size != matrix2._horizontal_size) {
        throw std::runtime_error("***FourRussiansMethod:: Error! Matrix shapes are not compatible.***");
    }

    size_t linear_combinations_count = two_pow(k);

    BitPackedMatrix multiplication_table(linear_combinations_count,matrix2._horizontal_size);
    multiplication_table.row_to_zeros(0);
    for (size_t i = 0; i < (matrix1._horizontal_size + k - 1) / k + 1; i++) {
        size_t bp = 1;
        size_t m = 0;
        for (size_t j = 1; j < linear_combinations_count; j++) {

            // building j-th row of multiplication table
            uint64_t* row_from_bottom = nullptr;
            row_from_bottom = RowFromBottom(matrix2, i, m + 1, k);
            for (size_t l = 0; l < multiplication_table._blocks_per_row; l++) {
                multiplication_table._data_ptr[j * multiplication_table._blocks_per_row + l] =
                        multiplication_table._data_ptr[(j - two_pow(m)) * multiplication_table._blocks_per_row + l] ^
                        ((row_from_bottom == nullptr) ? static_cast<uint64_t>(0) : row_from_bottom[l]);
            }

            if (bp == 1) {
                bp = j + 1;
                m  = m + 1;
            } else {
                bp = bp - 1;
            }
        }

        //std::cout << "Multiplication table is " << std::endl;
        //std::cout << multiplication_table << std::endl;

        size_t mul_index = 0;
        for (size_t j = 0; j < matrix1._vertical_size; j++) {
            mul_index = compute_index(matrix1, i, k, j);
            //std::cout << "Current index is " << mul_index << std::endl;
            res_matrix.xor_to_row(j, mul_index, multiplication_table);
        }
    }
}



void print_memory_block(uint64_t* ptr, size_t uint_to_print_num) {
    for (size_t i = 0; i < uint_to_print_num; i++) {
        std::cout << ptr[i] << std::endl;
    }
}

void print_memory_block_like_table(uint64_t* ptr, size_t vsize, size_t hsize) {
    for (size_t i = 0; i < vsize; i++) {
        for (size_t j = 0; j < hsize; j++) {
            std::cout << ptr[i * hsize + j] << " ";
        }
        std::cout << " line number is " << i << std::endl;
    }
}

void set_memory_block_with(uint64_t* ptr, size_t value, size_t uint_to_set_num) {
    for (size_t i = 0; i < uint_to_set_num; i++) {
        ptr[i] = 0;
    }
}

void set_memory_2d_block_with(uint64_t* ptr, size_t value, size_t vsize, size_t hsize) {
    for (size_t i = 0; i < vsize; i++) {
        set_memory_block_with(ptr + hsize * i, value, hsize);
    }
}

#define MATRIX_BLOCK_SIZE_IN_UINT64 10
#define MULTABLE_BLOCKS_STORED_COUNT 60

void FourRussiansMethodBlockWiseK4(const BitPackedMatrix& matrix1, const BitPackedMatrix& matrix2,
                                     BitPackedMatrix& res_matrix, size_t flag8 = 0) {
    // Let's check matrix's shapes compatibility
    if (matrix1._vertical_size != matrix2._horizontal_size) {
        throw std::runtime_error("***FourRussiansMethod:: Error! Matrix shapes are not compatible.***");
    }

    size_t k = 4;

    if (flag8) {
        k = 8;
    }

    size_t linear_combinations_count = two_pow(k);


    auto first_block = static_cast<uint64_t*>(malloc(MATRIX_BLOCK_SIZE_IN_UINT64 * sizeof(uint64_t)));
    auto res_block = static_cast<uint64_t*>(malloc(MULTABLE_BLOCKS_STORED_COUNT * MATRIX_BLOCK_SIZE_IN_UINT64 * sizeof(uint64_t)));
    auto mul_table_block = static_cast<uint64_t*>(malloc(MULTABLE_BLOCKS_STORED_COUNT * linear_combinations_count * sizeof(uint64_t)));

    set_memory_2d_block_with(mul_table_block, 0, linear_combinations_count, MULTABLE_BLOCKS_STORED_COUNT);
    set_memory_2d_block_with(res_block, 0, MATRIX_BLOCK_SIZE_IN_UINT64, MULTABLE_BLOCKS_STORED_COUNT);

    // initializing first row of mul_table_block
    for (size_t i = 0; i < MULTABLE_BLOCKS_STORED_COUNT; i++) {
        mul_table_block[i] = 0;
    }

    size_t blocks_per_column = (matrix1._horizontal_size + MATRIX_BLOCK_SIZE_IN_UINT64 - 1) / MATRIX_BLOCK_SIZE_IN_UINT64;
    size_t mul_blocks_per_linear_combination = (matrix2._blocks_per_row + MULTABLE_BLOCKS_STORED_COUNT - 1) / MULTABLE_BLOCKS_STORED_COUNT;
    for (size_t j = 0; j < matrix1._blocks_per_row; j++) {

        // Now we need to build linear combination table or rather the first 'MULTABLE_BLOCKS_STORED_COUNT' of its blocks
        for (size_t i = 0; i < 64 / k; i++) {
            //std::cout << "i is " << i;
            //std::cout << " j is " << j << std::endl;
            size_t mask = build_filled_mask(k) << i * k;

            //std::cout << "mask is " << mask << std::endl;

            for (size_t mul_block = 0; mul_block < mul_blocks_per_linear_combination; mul_block++) {
                size_t current_multable_block_start = mul_block * MULTABLE_BLOCKS_STORED_COUNT;

                size_t bp = 1;
                size_t m = 0;
                for (size_t row = 1; row < linear_combinations_count; row++) {
                    uint64_t *row_from_bottom = nullptr;
                    row_from_bottom = RowFromBottom(matrix2, j * (64 / k) + i, m + 1, k);


                    uint64_t tmp;
                    //std::cout << "Mul table row " << row << std::endl;
                    for (size_t l = 0; l < MULTABLE_BLOCKS_STORED_COUNT; l++) {
                        tmp = 0;
                        if ((row_from_bottom != nullptr) &&
                            (current_multable_block_start + l < matrix2._blocks_per_row)) {
                            tmp = row_from_bottom[current_multable_block_start + l];
                        }
                        mul_table_block[row * MULTABLE_BLOCKS_STORED_COUNT + l] = \
                                mul_table_block[(row - two_pow(m)) * MULTABLE_BLOCKS_STORED_COUNT + l] ^ tmp;
                    }


                    if (bp == 1) {
                        bp = row + 1;
                        m = m + 1;
                    } else {
                        bp = bp - 1;
                    }
                }

                for (size_t mat1_block = 0; mat1_block < blocks_per_column; mat1_block++) {
                    // Now we load matrix1 block in column j with number mat1_block
                    size_t tmp;
                    for (size_t block_row = 0; block_row < MATRIX_BLOCK_SIZE_IN_UINT64; block_row++) {
                        tmp = 0;
                        if (mat1_block * MATRIX_BLOCK_SIZE_IN_UINT64 + block_row < matrix1._vertical_size) {
                            tmp = matrix1._data_ptr[
                                    (mat1_block * MATRIX_BLOCK_SIZE_IN_UINT64 + block_row) * matrix1._blocks_per_row +
                                    j];
                        }
                        first_block[block_row] = tmp;
                    }


                    // compute res_block
                    size_t index = 0;
                    for (size_t first_block_row = 0; first_block_row < MATRIX_BLOCK_SIZE_IN_UINT64; first_block_row++) {
                        
                        index = rotate_uint((first_block[first_block_row] & mask) >> i * k, k);

                        for (size_t mb_p = 0; mb_p < MULTABLE_BLOCKS_STORED_COUNT; mb_p++) {
                            res_block[first_block_row * MULTABLE_BLOCKS_STORED_COUNT + mb_p] = mul_table_block[
                                    index * MULTABLE_BLOCKS_STORED_COUNT + mb_p];
                        }
                    }

                    // drop res_block to res_matrix
                    for (size_t a1 = 0; a1 < MATRIX_BLOCK_SIZE_IN_UINT64; a1++) {
                        for (size_t a2 = 0; a2 < MULTABLE_BLOCKS_STORED_COUNT; a2++) {
                            size_t vert_index = mat1_block * MATRIX_BLOCK_SIZE_IN_UINT64 + a1;
                            size_t hor_index = current_multable_block_start + a2;
                            if ((vert_index < res_matrix._vertical_size)  && (hor_index < res_matrix._blocks_per_row)) {
                                res_matrix._data_ptr[vert_index * matrix1._blocks_per_row + \
                                hor_index] ^= res_block[a1 * MULTABLE_BLOCKS_STORED_COUNT + a2];
                            } else {
                                continue;
                            }
                        }
                    }
                }
            }
        }
    }


    // free memory
    free(first_block);
    free(res_block);
    free(mul_table_block);
}

#undef MATRIX_BLOCK_SIZE_IN_UINT64
#undef MULTABLE_BLOCKS_STORED_COUNT