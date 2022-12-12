#include <iostream>
#include <fstream>
#include <filesystem>
#include "BitPackedMatrix.hpp"

int main() {

    std::ifstream fin;
    fin.open("./input.txt");


    std::ofstream runtime_stream;
    runtime_stream.open("./FRM_runtime_info", std::ios::app);

    int n = 0;
    fin >> n;

    std::ofstream fout;
    fout.open((std::string("./cpp_output_") + std::to_string(n) + std::string(".txt")).c_str());


    BitPackedMatrix mat1(n, n, fin);
    BitPackedMatrix mat2(n, n, fin);
    BitPackedMatrix res_mat(n, n);
    res_mat.fill_with_zeros();

    unsigned long long start_time = clock();
    FourRussiansMethod(mat1, mat2, res_mat, 4);
    unsigned long long end_time = clock();

    runtime_stream << n << "," << (end_time - start_time) / (CLOCKS_PER_SEC / 1000) << std::endl;

    fout << res_mat;

    fin.close();
    fout.close();
    runtime_stream.close();

    return 0;
}
