from sklearn.ensemble import GradientBoostingRegressor
import pandas as pd
import numpy as np
from lightgbm import LGBMRegressor


"""
 Внимание!
 В проверяющей системе имеется проблема с catboost.
 При использовании этой библиотеки, в скрипте с решением необходимо инициализировать метод с
 использованием `train_dir` как показано тут:
 CatBoostRegressor(train_dir='/tmp/catboost_info')
"""


def count_listed_data(col):
    res_dict = {}
    for i in col:
        if isinstance(i, list):
            for j in i:
                if j in res_dict:
                    res_dict[j] += 1
                    continue
                res_dict[j] = 1
            continue
        if i in res_dict:
            res_dict[i] += 1
            continue
        res_dict[i] = 1
    return res_dict


def encode_listed_data(col, count_listed_output):
    res = np.zeros(len(count_listed_output))
    encode_order = []
    for key in count_listed_output.keys():
        encode_order.append((key, count_listed_output[key]))
    # encode_order = sorted(encode_order, lambda x: x[1], reverse=True)
    for i in col:
        row = np.zeros(len(encode_order))
        if isinstance(i, list):
            encode_set = set(i)
        else:
            encode_set = set([i])

        for j in range(len(encode_order)):
            if encode_order[j][0] in encode_set:
                row[j] = 1
        res = np.vstack((res, row))
    return np.delete(res, 0, 0)


def preprocess_gender(gender):
    if gender == 'Male':
        return 1
    elif gender == 'Female':
        return -1
    else:
        return 0


class Solution:
    def __init__(self):
        self.categorical = ['genres', 'directors',
                            'filming_locations', 'keywords']
        self.attr_count_array = []

    def preprocess_data(self, X, predict_flag=False):
        data = X
        data.actor_0_gender = X.actor_0_gender.apply(preprocess_gender)
        data.actor_1_gender = X.actor_1_gender.apply(preprocess_gender)
        data.actor_2_gender = X.actor_2_gender.apply(preprocess_gender)
        categorical_dummies = np.zeros(X.shape[0])[:, None]
        # self.attr_count_array = []
        for i in range(self.categorical.__len__()):
            attr = self.categorical[i]
            if not predict_flag:
                attr_count = count_listed_data(X[attr])
                self.attr_count_array.append(attr_count.copy())
            else:
                attr_count = self.attr_count_array[i]
            categorical_dummies = np.hstack((categorical_dummies,
                                             encode_listed_data(X[attr], attr_count)))
        categorical_dummies = np.delete(categorical_dummies, np.s_[:1], 1)
        categorical_dummies = np.hstack((categorical_dummies,
                                         data.actor_0_gender.values[:, None],
                                         data.actor_1_gender.values[:, None],
                                         data.actor_2_gender.values[:, None]))
        # print('categorical shape is ', categorical_dummies.shape)
        non_categorical_data = data.drop(columns=self.categorical + ['actor_0_gender',
                                                                     'actor_1_gender',
                                                                     'actor_2_gender'])
        # print('shit is dropped')
        self.categorical_data = categorical_dummies
        self.non_categorical_data = non_categorical_data

    def fit(self, X, y):
        self.preprocess_data(X)
        # print('Preprocessed data!')
        self.categorical_model = LGBMRegressor(learning_rate=0.009,
                                               max_depth=10,
                                               n_estimators=1200)
        self.non_categorical_model = LGBMRegressor(learning_rate=0.001,
                                                   max_depth=3,
                                                   n_estimators=9743)
        self.meta_model = LGBMRegressor(learning_rate=0.01,
                                        max_depth=10,
                                        n_estimators=1000)
        self.categorical_model.fit(self.categorical_data, y)
        self.non_categorical_model.fit(self.non_categorical_data, y)
        categorical_pred = self.categorical_model.predict(
            self.categorical_data)
        non_categorical_pred = self.non_categorical_model.predict(
            self.non_categorical_data)

        meta_train = np.hstack((self.categorical_data, categorical_pred[:, None],
                                non_categorical_pred[:, None]))
        self.meta_model.fit(meta_train, y)

    def predict(self, X):
        self.preprocess_data(X, predict_flag=True)
        cat_pred = self.categorical_model.predict(self.categorical_data)
        non_cat_pred = self.non_categorical_model.predict(
            self.non_categorical_data)
        meta_objects = np.hstack((self.categorical_data, cat_pred[:, None],
                                  non_cat_pred[:, None]))
        pred = self.meta_model.predict(meta_objects)
        return pred


def train_model_and_predict(train_file: str, test_file: str) -> np.ndarray:
    """
    This function reads dataset stored in the folder, trains predictor and returns predictions.
    :param train_file: the path to the training dataset
    :param test_file: the path to the testing dataset
    :return: predictions for the test file in the order of the file lines (ndarray of shape (n_samples,))
    """

    df_train = pd.read_json(train_file, lines=True)
    df_test = pd.read_json(test_file, lines=True)

    # remove categorical variables
    y_train = df_train["awards"]
    del df_train["awards"]

    regressor = Solution()
    regressor.fit(df_train, y_train)
    return regressor.predict(df_test)
