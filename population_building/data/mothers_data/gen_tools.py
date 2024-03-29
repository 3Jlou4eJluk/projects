import numpy as np
import numba
import regex as re
from scipy import stats

spec = [
    ('ptr_', numba.int64),               # a simple scalar field
    ('arr_', numba.int64[:]),            # an array field
]


@numba.experimental.jitclass(spec)
class TableDistributionGenerator:
    def __init__(self, arr, shuffle=False):
        self.ptr_ = 0
        self.arr_ = arr.copy()
        if shuffle:
            np.random.shuffle(self.arr_)

    def get_next(self):
        res = 0
        if self.ptr_ < self.arr_.shape[0]:
            res = self.arr_[self.ptr_]
            self.ptr_ += 1
        else:
            np.random.shuffle(self.arr_)
            self.ptr_ = 1
            res = self.arr_[0]
        return res

    def reload_seq(self, shuffle=False):
        self.ptr_ = 0
        if shuffle:
            np.random.shuffle(self.arr_)

    def get_state(self):
        return self.ptr_

    def set_state(self, state):
        self.ptr_ = state


proba_spec = [
    ('prob_arr_', numba.float64[:]),
    ('values_', numba.int64[:]),
    ('gen_arr_', numba.int64[:])
]


@numba.experimental.jitclass(proba_spec)
class ProbaTableDistributionGenerator:
    def __init__(self, prob_arr, values):
        self.prob_arr_ = prob_arr
        self.values_ = values
        self.gen_arr_ = np.repeat(values, (prob_arr * 1000000).astype('int64'))
        np.random.shuffle(self.gen_arr_)

        if len(prob_arr) != len(values):
            raise RuntimeError

    def get_next(self):
        return self.gen_arr_[np.random.randint(0, self.gen_arr_.shape[0]-1)]


def get_diap(string):
    l = re.findall(r"\d+", string)
    for i in range(len(l)):
        l[i] = int(l[i])
    if len(l) == 1:
        l.append(np.int64(100))
    return np.array(l)


@numba.njit
def compute_partner_age_range(age, lb, rb):
    return np.array([lb + age, rb + age], dtype='float64')


@numba.njit
def random_num_from_range(a, b):
    return np.random.rand(1)[0] * (b - a) + a


@numba.njit
def generate_pair(agents_db, hhs_db, married_men_age_range_gen: ProbaTableDistributionGenerator,
                  agents_db_pos, hhs_db_pos, last_id, range_table, lb, rb):
    hhs_id = hhs_db[hhs_db_pos, 0]

    head_age_range = range_table[married_men_age_range_gen.get_next()]
    head_age = int(random_num_from_range(head_age_range[0], head_age_range[1]))

    partner_age_range = compute_partner_age_range(head_age, lb, rb)
    partner_age = int(random_num_from_range(partner_age_range[0], partner_age_range[1]))

    head_row = np.array([last_id + 1, head_age, 1, hhs_id])
    partner_row = np.array([last_id + 2, partner_age, 0, hhs_id])
    agents_db[agents_db_pos] = head_row
    agents_db[agents_db_pos + 1] = partner_row

    # текущее записанное в домохозяйство число агентов
    cur_count = hhs_db[hhs_db_pos, 2]
    hhs_db[hhs_db_pos, 3 + cur_count] = (last_id + 1)
    hhs_db[hhs_db_pos, 4 + cur_count] = (last_id + 2)

    # обновляем число людей в домохозяйствах
    hhs_db[hhs_db_pos, 2] += 2
    return agents_db_pos + 2, last_id + 2


@numba.njit
def generate_random_person(agents_db, hhs_db, adult_people_age_range_generator: ProbaTableDistributionGenerator,
                           agents_db_pos, hhs_db_pos, last_id, range_table):
    hhs_id = hhs_db[np.int64(hhs_db_pos)][0]
    cur_count = hhs_db[hhs_db_pos, 2]
    if cur_count >= 6:
        return agents_db_pos, last_id

    age_range = range_table[adult_people_age_range_generator.get_next()]
    age = int(random_num_from_range(age_range[0], age_range[1]))
    sex = np.random.randint(0, 2)
    agent_row = np.array([last_id + 1, age, sex, hhs_id])
    agents_db[agents_db_pos] = agent_row

    hhs_db[hhs_db_pos, 3 + cur_count] = (last_id + 1)

    # обновляем число людей в домохозяйствах
    hhs_db[hhs_db_pos, 2] += 1
    return agents_db_pos + 1, last_id + 1
