import os

test_size_list = [1024, 2048, 4096, 8192, 16384]
#test_size_list = [5, 10, 20]

for i in test_size_list:
	os.system("python matrix_generation_script.py " + str(i) + " | " + "./a.out")