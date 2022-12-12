//
// Created by mishanya on 12/1/22.
//

#ifndef METHODOFFOURRUSSIANS_BITPACKEDMATRIX_HPP
#define METHODOFFOURRUSSIANS_BITPACKEDMATRIX_HPP

class BitPackedMatrix {
public:
    BitPackedMatrix();
    BitPackedMatrix(size_t, size_t);
    BitPackedMatrix(size_t, size_t, std::istream&);
    ~BitPackedMatrix();

    void xor_to_row(size_t, size_t, const BitPackedMatrix&);
    void row_to_zeros(size_t);
    void fill_with_zeros();
    void set_row_value(size_t to_row, size_t from_row, const BitPackedMatrix& from_matrix);


    friend std::ostream& operator<<(std::ostream&, const BitPackedMatrix&);
    friend void FourRussiansMethod(const BitPackedMatrix&, const BitPackedMatrix&, BitPackedMatrix&, size_t k);
    friend uint64_t* RowFromBottom(const BitPackedMatrix& matrix, size_t block_number, size_t num_from_end, size_t k);
    friend size_t compute_index(const BitPackedMatrix& matrix, size_t matrix_block_num, size_t k, size_t row_num);

    class Row {
    public:
        Row(size_t, BitPackedMatrix&, bool allocate_mem_flag);
        ~Row();

        Row& operator^(const Row& oth);
        Row& operator=(const Row& oth);

    private:
        size_t _row_num;
        bool _allocated_mem_flag;
        BitPackedMatrix& _from_matrix_object;
        BitPackedMatrix* _row_storage;
        uint64_t* _row_start;
    };

    Row get_row(size_t line);


    uint64_t* _data_ptr;
    size_t _allocated_mem_value;
    size_t _vertical_size, _horizontal_size;
    size_t _system_horizontal_size;
    size_t _blocks_per_row;
};

size_t compute_index(const BitPackedMatrix& matrix, size_t matrix_block_num, size_t k, size_t row_num);
size_t rotate_uint(size_t uint_to_rotate, size_t);
size_t two_pow(size_t);

void FourRussiansMethod(const BitPackedMatrix& matrix1, const BitPackedMatrix& matrix2, BitPackedMatrix& res_matrix,
                        size_t k);

#endif //METHODOFFOURRUSSIANS_BITPACKEDMATRIX_HPP
