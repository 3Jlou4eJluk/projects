import numpy as np
import pandas as pd
import numba
from tqdm import tqdm


@numba.njit
def search_range(age_range_table, age):
    for i in range(age_range_table.shape[0]):
        if (age >= age_range_table[i][0]) and (age <= age_range_table[i][1]):
            return i
    return age_range_table.shape[0] - 1


def contacts_super_count(hhs_database: np.ndarray, agents_database: np.ndarray, age_range_table, agents_count):
    max_age = np.max(agents_database[:, 1])
    contacts_2d_count_array = np.zeros((max_age + 1, max_age + 1), dtype=np.float64)
    for i in range(hhs_database.shape[0]):
        hhs_type = hhs_database[i, 1]
        if hhs_type == 1:
            continue
        for participant_i in range(hhs_type):
            participant_id = hhs_database[i, 3 + participant_i]
            participant_age = agents_database[participant_id, 1]
            for contact_member_i in range(hhs_type):
                if contact_member_i == participant_i:
                    continue
                contact_id = hhs_database[i, 3 + contact_member_i]
                contact_age = agents_database[contact_id, 1]
                contacts_2d_count_array[contact_age, participant_age] += 1
    return contacts_2d_count_array
