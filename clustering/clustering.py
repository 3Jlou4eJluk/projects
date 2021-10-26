"""
координаты будем хранить в двумерном массиве
количество групп подаётся на вход
"""

import numpy as np
import matplotlib.pyplot as plt
import random
from sklearn.datasets import make_blobs
from time import time

def dot_dist(x1, y1, x2, y2):
    return np.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))


N = 1000
epsilon = 0.0
max_iters_below_eps = 1
max_iters = 300
DOTS_SIZE = 5
colors = ['red', 'blue', 'green', 'purple', 'pink', 'gray', 'aqua']

k = int(input())
x, y = make_blobs(n_samples = N, n_features = 2, centers = k, random_state = 0)
print("blobs maked")

a = time()
iters_below_eps = 0
iters = 0
mids = np.zeros((k, 2)) # координаты центров

# выбираем k точек

# сначала выберем первую
rand_dot = random.randint(0, N - 1)
mids[0][0] = x[rand_dot][0]
mids[0][1] = x[rand_dot][1]

for i in range(1, k):
    max_dist_sum = 0
    maxx = 0
    maxy = 0
    for p in range(N):
        dist_sum = 0.0
        for j in range(0, i):
            dist_sum += dot_dist(mids[j][0], mids[j][1], x[p][0], x[p][1])
        if dist_sum > max_dist_sum:
            max_dist_sum = dist_sum
            maxx = x[p][0]
            maxy = x[p][1]
            dist_sum = 0
    mids[i][0] = maxx
    mids[i][1] = maxy

while True:
    maxdelta = 0
    iters += 1
    # определяем, что к чему принадлежит
    for i in range(N):
        y[i] = np.argmin([dot_dist(mids[j][0], mids[j][1], x[i][0], x[i][1]) for j in range(k)])

    maxdelta = 0
    for i in range(k):
        oldmidx = mids[i][0]
        oldmidy = mids[i][1]
        quan = 0
        midx = 0
        midy = 0
        for j in range(N):
            if y[j] == i:
                midx += x[j][0]
                midy += x[j][1]
                quan += 1
        if quan > 0:
            midx /= quan
            midy /= quan
            mids[i][0] = midx
            mids[i][1] = midy
        delta = dot_dist(mids[i][0], mids[i][1], oldmidx, oldmidy)
        if delta > maxdelta:
            maxdelta = delta

    if maxdelta <= epsilon:
        iters_below_eps += 1
    if (iters_below_eps >= max_iters_below_eps) or (iters >= max_iters):
        break
a = time() - a
print("Finished:")
print("iters: ", iters)
print("iters_below_eps: ", iters_below_eps)
print("seconds: ", a)

# plt.scatter([mids[i][0] for i in range(k)], [mids[i][1] for i in range(k)], 200, 'red')

# рисуем кластеры
for i in range(k):
    plt.scatter([x[j][0] for j in range(N) if i == y[j]], [x[j][1] for j in range(N) if i == y[j]],
                DOTS_SIZE, colors[i % 7])
plt.grid()
plt.show()
