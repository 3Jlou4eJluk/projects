import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from scipy.stats import norm
from tqdm import tqdm

from gen_tools import ProbaTableDistributionGenerator
from gen_tools import get_diap
from gen_tools import generate_pair
from gen_tools import generate_random_person
from gen_tools import generate_random_person_based
from gen_tools import random_num_from_range
from gen_tools import generate_pair_from_child_age
from gen_tools import generate_child_with_specified_number

from analysis_tools import contacts_count
from analysis_tools import contacts_super_count


class InfectionModelExperimental:
    def __init__(self, agents_type, hhs_count, partner_age_dispersion):
        self.AGENTS_TYPE = agents_type
        self.HHS_COUNT = hhs_count
        self.PARTNER_AGE_DISPERSION = partner_age_dispersion
        self.agents_database = None
        self.hhs_database = None
        self.age_range_table = None
        self.agents_count = None

    def load_process_data(self):
        hhs_data = pd.read_excel('./data/bryansk_data.xlsx')
        df = pd.read_excel('./data/Age_sex_count_v1.xlsx')
        if self.AGENTS_TYPE == 'urban':
            men_marriage_data = pd.read_excel(
                './population_building_data/marriage_data/bryansk_urban_men_marriage_data.xlsx')
        else:
            men_marriage_data = pd.read_excel(
                './population_building_data/marriage_data/bryansk_rural_men_marriage_data.xlsx')
        pair1_df = pd.read_excel('population_building_data/pair1.xlsx')
        pair2_df = pd.read_excel('population_building_data/pair2.xlsx')
        pair3_df = pd.read_excel('population_building_data/pair3.xlsx')
        summary = pd.read_excel('population_building_data/summary.xlsx')

        pair1_df_with_childs = pd.read_excel('population_building_data/pair1_v2.xlsx')
        pair2_df_with_childs = pd.read_excel('population_building_data/pair2_v2.xlsx')
        pair3_df_with_childs = pd.read_excel('population_building_data/pair3_v2.xlsx')

        mothers_df = pd.read_csv('./data/mothers_data/BRaO2015-2021.txt')
        mothers_df = mothers_df[mothers_df.Year == 2021]
        mothers_df = mothers_df[mothers_df.Reg == 1115]

        mask = df['region'].apply(lambda x: x.find('Брянская область') != -1)
        data = df[mask]

        age_range_table = np.zeros((data.shape[0], 2))
        self.age_range_table = age_range_table

        for i in range(data.shape[0]):
            age_range_table[i] = get_diap(data.age_range.values[i])

        men_data = data[['age_range', 'men_urban']].rename(columns={'men_urban': 'men_count'})
        women_data = data[['age_range', 'women_urban']].rename(columns={'women_urban': 'women_count'})
        if self.AGENTS_TYPE == 'rural':
            men_data = data[['age_range', 'men_rural']].rename(columns={'men_rural': 'men_count'})
            women_data = data[['age_range', 'women_rural']].rename(columns={'women_rural': 'women_count'})

        men_count_arr = men_data.men_count.values
        women_count_arr = women_data.women_count.values
        agents_props = (men_count_arr + women_count_arr) / np.sum(men_count_arr + women_count_arr)

        # создаём генераторы возрастов детей и возрослых агентов
        childs_age_range_proba = (men_count_arr + women_count_arr)[:4] / np.sum((men_count_arr + women_count_arr)[:4])
        agents_age_range_proba = (men_count_arr + women_count_arr)[4:] / np.sum((men_count_arr + women_count_arr)[4:])
        childs_age_range_gen = ProbaTableDistributionGenerator(childs_age_range_proba, np.array(range(0, 4)))
        adult_agents_age_range_gen = ProbaTableDistributionGenerator(agents_age_range_proba,
                                                                     np.array(range(4, age_range_table.shape[0])))

        hhs_props = hhs_data.copy()
        for i in range(1, 7):
            # доля домохозяйств каждого типа в процентах
            col = 'with_' + str(i) + '_members'
            hhs_props[col] = hhs_props[col] / hhs_props['household_count']
            hhs_props.rename(columns={col: 'type_' + str(i)}, inplace=True)

        hhs_props.drop(columns=['household_count', 'people_sum', 'with_6_members_people_sum', 'average_size'],
                       inplace=True)

        type_row = 1
        if self.AGENTS_TYPE == 'rural':
            type_row = 2

        hhs_of_each_type_count = (hhs_props.iloc[type_row, 1:] * self.HHS_COUNT).astype('int64').values

        # генерируем домохозяйства
        hhs_id = np.array(range(self.HHS_COUNT), dtype=np.int64)
        hhs_type_repeated = np.repeat(range(1, 7), hhs_of_each_type_count).astype('int64')
        # общее число агентов
        agents_sum = np.sum(hhs_type_repeated)
        hhs_type = np.zeros(self.HHS_COUNT, dtype=np.int64)
        hhs_type[:hhs_type_repeated.shape[0]] = hhs_type_repeated
        for i in range(hhs_type_repeated.shape[0], self.HHS_COUNT):
            hhs_type[i] = 1
            agents_sum += 1

        self.agents_count = (agents_props * agents_sum).astype('int64')

        hhs_actual_count = np.zeros(self.HHS_COUNT, dtype=np.int64)
        hhs_m1 = np.full(self.HHS_COUNT, -1, dtype=np.int64)
        hhs_m2 = np.full(self.HHS_COUNT, -1, dtype=np.int64)
        hhs_m3 = np.full(self.HHS_COUNT, -1, dtype=np.int64)
        hhs_m4 = np.full(self.HHS_COUNT, -1, dtype=np.int64)
        hhs_m5 = np.full(self.HHS_COUNT, -1, dtype=np.int64)
        hhs_m6 = np.full(self.HHS_COUNT, -1, dtype=np.int64)

        hhs_db = np.column_stack((hhs_id, hhs_type, hhs_actual_count, hhs_m1, hhs_m2, hhs_m3, hhs_m4, hhs_m5, hhs_m6))

        married_men_proba = men_marriage_data.married.values[1:] / np.sum(men_marriage_data.married.values[1:])
        married_men_age_range_gen = ProbaTableDistributionGenerator(married_men_proba, np.array(range(4, 18)))

        print('Creating pair generators')
        # Создаём генератор пар
        pair1_proba = pair1_df.iloc[0]['private_households'] / summary.iloc[0]['private_hhs']
        pair2_proba = pair2_df.iloc[0]['private_households'] / summary.iloc[0]['private_hhs']
        pair3_proba = pair3_df.iloc[0]['private_households'] / summary.iloc[0]['private_hhs']

        pair_2m_proba = np.array((0,
                                  pair1_df.iloc[0]['2_members'] / summary.iloc[0]['with_2_members'],
                                  pair2_df.iloc[0]['2_members'] / summary.iloc[0]['with_2_members'],
                                  pair3_df.iloc[0]['2_members'] / summary.iloc[0]['with_2_members']
                                  ))
        pair_2m_proba[0] = 1 - np.sum(pair_2m_proba[1:])

        pair_3m_proba = np.array((0,
                                  pair1_df.iloc[0]['3_members'] / summary.iloc[0]['with_3_members'],
                                  pair2_df.iloc[0]['3_members'] / summary.iloc[0]['with_3_members'],
                                  pair3_df.iloc[0]['3_members'] / summary.iloc[0]['with_3_members']
                                  ))
        pair_3m_proba[0] = 1 - np.sum(pair_3m_proba[1:])

        pair_4m_proba = np.array((0,
                                  pair1_df.iloc[0]['4_members'] / summary.iloc[0]['with_4_members'],
                                  pair2_df.iloc[0]['4_members'] / summary.iloc[0]['with_4_members'],
                                  pair3_df.iloc[0]['4_members'] / summary.iloc[0]['with_4_members']
                                  ))
        pair_4m_proba[0] = 1 - np.sum(pair_4m_proba[1:])

        pair_5m_proba = np.array((0,
                                  pair1_df.iloc[0]['5_members'] / summary.iloc[0]['with_5_members'],
                                  pair2_df.iloc[0]['5_members'] / summary.iloc[0]['with_5_members'],
                                  pair3_df.iloc[0]['5_members'] / summary.iloc[0]['with_5_members']
                                  ))
        pair_5m_proba[0] = 1 - np.sum(pair_5m_proba[1:])

        pair_6m_proba = np.array((0,
                                  pair1_df.iloc[0]['6_members'] / summary.iloc[0]['with_6_members'],
                                  pair2_df.iloc[0]['6_members'] / summary.iloc[0]['with_6_members'],
                                  pair3_df.iloc[0]['6_members'] / summary.iloc[0]['with_6_members']
                                  ))
        pair_6m_proba[0] = 1 - np.sum(pair_6m_proba[1:])

        pair_2m_gen = ProbaTableDistributionGenerator(pair_2m_proba, np.array(range(0, 4)))
        pair_3m_gen = ProbaTableDistributionGenerator(pair_3m_proba, np.array(range(0, 4)))
        pair_4m_gen = ProbaTableDistributionGenerator(pair_4m_proba, np.array(range(0, 4)))
        pair_5m_gen = ProbaTableDistributionGenerator(pair_5m_proba, np.array(range(0, 4)))
        pair_6m_gen = ProbaTableDistributionGenerator(pair_6m_proba, np.array(range(0, 4)))

        # создаём генераторы детей
        print('Creating children generators')
        p1_3m_childs_proba = np.zeros(4)
        p1_3m_childs_proba[1:] = pair1_df_with_childs.iloc[1:4]['with_3_members'] / \
                                 pair1_df_with_childs.iloc[0]['with_3_members']
        p1_3m_childs_proba[0] = 1 - np.sum(p1_3m_childs_proba[1:])

        p1_4m_childs_proba = np.zeros(4)
        p1_4m_childs_proba[1:] = pair1_df_with_childs.iloc[1:4]['with_4_members'] / \
                                 pair1_df_with_childs.iloc[0]['with_4_members']
        p1_4m_childs_proba[0] = 1 - np.sum(p1_4m_childs_proba[1:])

        p1_5m_childs_proba = np.zeros(4)
        p1_5m_childs_proba[1:] = pair1_df_with_childs.iloc[1:4]['with_5_members'] / \
                                 pair1_df_with_childs.iloc[0]['with_5_members']
        p1_5m_childs_proba[0] = 1 - np.sum(p1_5m_childs_proba[1:])

        p1_6m_childs_proba = np.zeros(4)
        p1_6m_childs_proba[1:] = pair1_df_with_childs.iloc[1:4]['with_6_members'] / \
                                 pair1_df_with_childs.iloc[0]['with_6_members']
        p1_6m_childs_proba[0] = 1 - np.sum(p1_6m_childs_proba[1:])

        p2_5m_childs_proba = np.zeros(4)
        p2_5m_childs_proba[1:] = pair2_df_with_childs.iloc[1:4]['with_5_members'] / \
                                 pair2_df_with_childs.iloc[0]['with_5_members']
        p2_5m_childs_proba[0] = 1 - np.sum(p2_5m_childs_proba[1:])

        p1_3m_childs_gen = ProbaTableDistributionGenerator(p1_3m_childs_proba, np.array(range(0, 4)))
        p1_4m_childs_gen = ProbaTableDistributionGenerator(p1_4m_childs_proba, np.array(range(0, 4)))
        p1_5m_childs_gen = ProbaTableDistributionGenerator(p1_5m_childs_proba, np.array(range(0, 4)))
        p1_6m_childs_gen = ProbaTableDistributionGenerator(p1_6m_childs_proba, np.array(range(0, 4)))
        p2_5m_childs_gen = ProbaTableDistributionGenerator(p2_5m_childs_proba, np.array(range(0, 4)))

        # генерируем возраста матери при родении первого ребёнка
        mothers_age_first_child_gen_arr = mothers_df.iloc[type_row][3 + 41: 3 + 41 * 2].values.astype('float64')
        mothers_age_second_child_gen_arr = mothers_df.iloc[type_row][3 + 41 * 2: 3 + 41 * 3].values.astype('float64')
        mothers_age_third_child_gen_arr = mothers_df.iloc[type_row][3 + 41 * 3: 3 + 41 * 4].values.astype('float64')

        mothers_age_first_child_gen_arr /= np.sum(mothers_age_first_child_gen_arr)
        mothers_age_second_child_gen_arr /= np.sum(mothers_age_second_child_gen_arr)
        mothers_age_third_child_gen_arr /= np.sum(mothers_age_third_child_gen_arr)

        mothers_age_first_child_gen = ProbaTableDistributionGenerator(prob_arr=mothers_age_first_child_gen_arr,
                                                                      values=np.array(range(15, 56), dtype=np.int64))
        mothers_age_second_child_gen = ProbaTableDistributionGenerator(prob_arr=mothers_age_second_child_gen_arr,
                                                                       values=np.array(range(15, 56), dtype=np.int64))
        mothers_age_third_child_gen = ProbaTableDistributionGenerator(prob_arr=mothers_age_third_child_gen_arr,
                                                                      values=np.array(range(15, 56), dtype=np.int64))

        # создадим генераторы pair для добавления братьев или сестёр партнёров
        pair_choose_gen = ProbaTableDistributionGenerator(prob_arr=np.array([0.6, 0.35, 0.05]),
                                                          values=np.array([0, 1, 2]))
        # создадим генераторы выбора между братом и сестрой
        sib_par_gen = ProbaTableDistributionGenerator(prob_arr=np.array([0.4, 0.6]),
                                                      values=np.array([0, 1]))

        # let's start main cycle
        # база агентов
        agents_base = np.zeros((agents_sum, 4))

        # computing partner age bounds
        gen = norm(loc=0, scale=self.PARTNER_AGE_DISPERSION)
        lb = gen.ppf(0.05)
        rb = gen.ppf(0.95)

        # computing age difference between brothers/sisters: first and second
        gen = norm(loc=4, scale=2)
        child_diff_bounds12 = np.array((gen.ppf(0.05), gen.ppf(0.95)))
        if child_diff_bounds12[0] < 0:
            child_diff_bounds12[0] = 0

        # computing age difference between brothers/sisters: second and third
        gen = norm(loc=6, scale=2)
        child_diff_bounds23 = np.array((gen.ppf(0.05), gen.ppf(0.95)))
        if child_diff_bounds23[0] < 0:
            child_diff_bounds23[0] = 0

        print("Starting households filling process")
        last_id = -1
        current_agent_pos = 0
        for i in tqdm(range(hhs_db.shape[0])):

            hhs_row = hhs_db[i]
            hhs_type = hhs_row[1]

            childs_count = 0
            pair_count = 0
            match hhs_type:
                case 2:
                    pair_count = pair_2m_gen.get_next()
                    childs_count = 0
                case 3:
                    pair_count = pair_3m_gen.get_next()
                    childs_count = 0
                    if pair_count:
                        childs_count = p1_3m_childs_gen.get_next()
                case 4:
                    pair_count = pair_4m_gen.get_next()
                    match pair_count:
                        case 1:
                            childs_count = p1_4m_childs_gen.get_next()
                        case 2:
                            childs_count = 0
                case 5:
                    pair_count = pair_5m_gen.get_next()
                    match pair_count:
                        case 1:
                            childs_count = p1_5m_childs_gen.get_next()
                        case 2:
                            childs_count = p2_5m_childs_gen.get_next()
                case 6:
                    pair_count = pair_6m_gen.get_next()
                    childs_count = 0
                case 1:
                    pair_count = 0
                    childs_count = 0

            last_child_age = 0
            bounds_tup = (0, 0)
            for j in range(1, childs_count + 1):
                if j == 2:
                    bounds_tup = child_diff_bounds12
                elif j == 3:
                    bounds_tup = child_diff_bounds23
                current_agent_pos, last_id, last_child_age = generate_child_with_specified_number(agents_base, hhs_db, last_child_age,
                                                                                                  j, childs_age_range_gen,
                                                                                                  current_agent_pos,
                                                                                                  i, last_id, age_range_table,
                                                                                                  bounds_tup[0], bounds_tup[1])

            last_mother_age = last_child_age
            mothers_age_gen = None
            pair_ages = np.full((2, 3), -1)
            for j in range(1, pair_count + 1):
                if (childs_count == 0) and (j == 1):
                    current_agent_pos, last_id, last_mother_age, _ = generate_pair(agents_base, hhs_db, married_men_age_range_gen,
                                                                                   current_agent_pos, i, last_id, age_range_table, lb, rb)
                    pair_ages[:, j - 1] = last_mother_age, _
                    continue
                if j == 1:
                    mothers_age_gen = mothers_age_first_child_gen
                elif j == 2:
                    mothers_age_gen = mothers_age_second_child_gen
                elif j == 3:
                    mothers_age_gen = mothers_age_third_child_gen

                third_pair_threshold = 60
                if last_mother_age > third_pair_threshold:
                    current_agent_pos, last_id, last_mother_age, _ = generate_pair(agents_base, hhs_db,
                                                                                   married_men_age_range_gen,
                                                                                   current_agent_pos, i, last_id,
                                                                                   age_range_table, lb, rb)
                    pair_ages[:, j - 1] = last_mother_age, _
                    continue
                current_agent_pos, last_id, last_mother_age, _ = generate_pair_from_child_age(agents_base, hhs_db,
                                                                                              last_mother_age,
                                                                                              mothers_age_gen,
                                                                                              current_agent_pos, i,
                                                                                              last_id, age_range_table,
                                                                                              lb, rb)
                pair_ages[:, j - 1] = last_mother_age, _

            other_count = hhs_type - pair_count * 2 - childs_count
            # print('pair count is ', pair_count)
            # print('childs count is ', childs_count)
            # print('other count is ', other_count)

            if hhs_type == 1:
                current_agent_pos, last_id, _ = generate_random_person(agents_base, hhs_db, adult_agents_age_range_gen,
                                                                       current_agent_pos, i, last_id, age_range_table)
            else:
                for j in range(other_count):
                    current_agent_pos, last_id, _ = generate_random_person(agents_base, hhs_db,
                                                                           adult_agents_age_range_gen,
                                                                           current_agent_pos, i, last_id,
                                                                           age_range_table)

        self.agents_database = agents_base
        self.hhs_database = hhs_db

    def draw_population_histogram(self, ax):
        agents_df = pd.DataFrame(data=self.agents_database.astype('int64'),
                                 columns=['id', 'age', 'sex', 'hhs_id'])
        ax.set_title('Age histogram')
        ax.set_xlabel('Participant age')
        ax.set_ylabel('Agents count')
        sns.histplot(data=agents_df, x='age', hue='sex', ax=ax, bins=17)
        print("Max age is ", np.max(agents_df.age))

    def draw_contact_heatmap(self, ax):
        contacts_count_array = contacts_super_count(hhs_database=self.hhs_database.astype('int64'),
                                                    agents_database=self.agents_database.astype('int64'),
                                                    age_range_table=self.age_range_table,
                                                    agents_count=self.agents_count)
        ax.set_title('Contacts count')
        ax.set_xlabel('Participant group')
        ax.set_ylabel('Contact group')
        sns.heatmap(contacts_count_array, ax=ax)
        ax.invert_yaxis()
