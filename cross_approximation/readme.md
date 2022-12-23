# Cross approximation


Cross approximation is the low-rank approximation method, which can be used in different areas such as data analysis or machine learning.


In cross_approx.py implemented 

1. function ***def search_max_volume_submatrix(matrix, rank, eps=1e-4, zero_threshold=1e-16, max_iters=50)***, which search set of rows and columns with cardinality 'rank' each.

2. function ***def build_cross_approx(matrix, rank, eps=1e-4, zero_threshold=1e-16, max_iters=50)***, which build cross approximation of matrix


Let's check algorithm on Hilbert matrix(with shape (1000, 1000))

![Hilbert](https://raw.githubusercontent.com/3Jlou4eJluk/projects/main/cross_approximation/img/dependence_plot.png)


In Cross_Approximation.ipynb you can check this algorithm on other matrix.
