# Matrix multiplication using Method of Four Russians

- runtime_info.txt contains "void FourRussians()" working time on matrix sizes: 1024, 2048, 4096, 8192, 16384

- python_generation_script.py generates 2 matrixes of size N(from input), put them in standart output, multiply them and put result into file.

- main.cpp takes shape and 2 matrixes from input.txt, multiply them and put multiplication result in file "./cpp_output_<n>.txt", where n is square size of matrixes

## Usage

1. make
2. ./a.out
3. input n
4. input matrixes
5. Output is first * second


## Features:

1. Implemented class BitPackedMatrix, which use uint64_t to store bits
2. Implemented [method of four russians](https://louridas.github.io/rwa/assignments/four-russians/)


## Important
Four Russians Method constant = 4, because a larger value does not allow efficient use of the cache.
The goal of the project is to learn how to use caching to improve the efficiency of the program.

Current work time on different boolean matrixes of shape (n, n): <br />
![Work time](https://raw.githubusercontent.com/3Jlou4eJluk/projects/main/four_russians_method/runtime_info.png)
