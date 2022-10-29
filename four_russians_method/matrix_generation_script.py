import numpy as np 
import sys

N = int(sys.argv[1])


a = np.eye(N)
for i in range(N):
	for j in range(0, i+1):
		a[i, j] = a[j, i] = np.random.randint(0, 2)

b = np.eye(N)
for i in range(N):
	for j in range(0, i+1):
		b[i, j] = b[j, i] = np.random.randint(0, 2)


print(str(N) + " " + str(N) + " " + str(N))
np.savetxt(sys.stdout, a, fmt="%i")
print(" ")
np.savetxt(sys.stdout, b, fmt="%i")

result_file = open('python_multiplication_matrix_result' + '_' + str(N) + '.txt', 'w')
np.savetxt(result_file, a.dot(b) % 2, fmt="%i")
