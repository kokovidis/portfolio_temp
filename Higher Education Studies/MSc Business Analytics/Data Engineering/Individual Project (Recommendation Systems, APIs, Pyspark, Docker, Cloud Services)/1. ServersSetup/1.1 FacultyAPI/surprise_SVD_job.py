from surprise import SVD
from surprise import Reader, Dataset #converts pandas dataframe to surprise objects
from surprise import accuracy
from surprise.model_selection import GridSearchCV

import pandas as pd

from collections import defaultdict

import pickle


#stage 1
ratings = pd.read_csv('/project/DataCollection/ratings.csv')
ratings['rating'] = ratings['rating'].astype(int)
ratings = ratings.drop('timestamp', axis=1)
reader = Reader(rating_scale=(0, 5)) #set the range of rating column
data = Dataset.load_from_df(ratings[['userId', 'movieId', 'rating']], reader)

# Select your best parameters for SVD
param_grid = {'n_factors':[80,100,120],
              'n_epochs': [15,20,25], 
              'lr_all': [0.002, 0.005, 0.01],
              'reg_all': [0.01,0.02,0.03],
              'random_state':[94]
             }
grid_search = GridSearchCV(SVD, param_grid, measures=['rmse'], cv=3, n_jobs=-1)
grid_search.fit(data)

best_model = grid_search.best_estimator['rmse']

# Get the best model
data = data.build_full_trainset()
best_model = best_model.fit(data)



#stage 2
#https://surprise.readthedocs.io/en/stable/FAQ.html?highlight=get%20top%20predictions#how-to-get-the-top-n-recommendations-for-each-user

def get_top_n(predictions, n=10):
    # First map the predictions to each user.
    top_n = defaultdict(list)
    for uid, iid, true_r, est, _ in predictions:
        top_n[uid].append((iid, est))

    # Then sort the predictions for each user and retrieve the k highest ones.
    for uid, user_ratings in top_n.items():
        user_ratings.sort(key=lambda x: x[1], reverse=True)
        top_n[uid] = user_ratings[:n]

    return top_n

# Than predict ratings for all pairs (u, i) that are NOT in the training set.
data_anti_testset = data.build_anti_testset()
predictions = best_model.test(data_anti_testset)

top_10 = get_top_n(predictions, n=10)


#stage 3
#Finally we save the recommendations to a pickle file in our local directory
f = open("top_10_recomm.pkl","wb")
pickle.dump(top_10,f)
f.close()