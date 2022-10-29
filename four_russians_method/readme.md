# Matrix multiplication using Method of Four Russians

- runtime_info.txt contains "void FourRussians()" working time on matrix sizes: 1024, 2048, 4096, 8192, 16384

- python_generation_script.py generates 2 matrixes of size N(from input), put them int standart output, multiply them and put them into file.

- Bitpacked_Boolean_Matrix.cpp takes shape and 2 matrixes from standart input, multiply them and put multiplication result in file.

## Usage

1. make
2. ./a.out
3. input m, n, k (first matrix shape are (m, n), second are (n, k), result are (m, k)
4. Output is first * second

You can use pipe to redirect python_generation_script.py output to Bitpacked_Boolean_Matrix.cpp like that

>python python_generation_script.py | ./a.out


## Features:

1. Implemented class Bitpacked_Boolean_Matrix, which use uint64_t to store bits
2. Implemented class BitPtr, whick makes it possible to assign a value to a bit
3. Implemented void FourRuissiansMethod() function, that Blockwise multiplies matrices
4. Implemented sequential data storage to optimize memory handling

## Important
Four Russians Method constant = 6, because a larger value does not allow efficient use of the cache.
The goal of the project is to learn how to use caching to improve the efficiency of the program.
