#!/usr/bin/env python
# coding: utf-8

# # Client's requests
# Below we make the calls to the several APIs that we have created. First we load the users to predict and the data files

# In[287]:


import pandas as pd
import requests
import json
import time

from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"


# In[288]:


ids = pd.read_csv('user_predictions.csv', header=None )
ids[0]= ids[0].astype(int)
ids_list = ids[0].tolist()
ids_list.sort() #sort() is by default inplace (we cannot reassign it to the same var)
ids_list


# In[289]:


ratings = pd.read_csv('/project/DataCollection/ratings.csv')
ratings['rating'] = ratings['rating'].astype(int)
ratings


# In[290]:


movies = pd.read_csv('/project/DataCollection/movies.csv')
movies


# In[291]:


ratings_titles = ratings.merge(movies, on='movieId', how='left')
ratings_titles = ratings_titles.drop('timestamp', axis=1)
ratings_titles.head(1)


# # Faculty API
# Below we get the recommendations from the API that we have deployed on Faculty

# In[76]:


## Internal - Faculty API

def faculty_pred(uid):
    url = 'https://svdsurprise.api.ucl.my.faculty.ai/predict/'
    url_id = url+str(uid)
    # Defining API-key
    headers = {"UserAPI-Key":"c07884p7ba32k6osq57jfr01q9if18rgi04v1ir51e2oqi8d5a"}
    r = requests.get(url_id, headers=headers) #headers=headers
    return pd.DataFrame(r.json())


# In[275]:


internal_api_pred = pd.DataFrame(columns=['userId', 'movieId', 'pred_rating'])

for uid in ids_list:
    fac_resp = faculty_pred(uid)
    fac_resp = fac_resp.loc[:,['userId', 'movieId', 'pred_rating']]
    internal_api_pred = internal_api_pred.append(fac_resp)


# In[276]:


internal_api_faculty_pred = internal_api_pred.merge(movies.loc[:,('movieId', 'title')], on='movieId' , how='left')
internal_api_faculty_pred['source'] = 'faculty'
internal_api_faculty_pred.head()


# # AWS API
# Below we get the recommendations from the API that we have deployed on AWS (from a the docker image that we have created)

# In[294]:


def als_AWS_pred(user_id, ratings_titles_df):
    req = ratings_titles_df.loc[ratings_titles_df.userId==user_id]
    req = req.loc[:,('userId','movieId','rating')]
    
    #req['userId'] = req.userId.astype(str)
    #req['rating'] = req.rating.astype(str)
    req = req.to_dict()
    url = 'http://3.87.154.194:8080'
    # Adding empty header as parameters are being sent in payload
    resp = requests.post(url, data=json.dumps(req)) #headers=headers #data=json.dumps(req)
    resp = json.loads(json.loads(resp.content))
    return pd.DataFrame(resp)
    #return json.loads(resp.content)


# In[295]:


aws_api_pred = pd.DataFrame(columns=['userId', 'title', 'prediction'])


start_time = time.time() #calculate execution time
for uid in ids_list:
    print("Parsing prediction for user: ", str(uid) )
    fac_resp = als_AWS_pred(uid, ratings_titles)
    fac_resp = fac_resp.loc[:,['userId', 'title', 'prediction']]
    aws_api_pred = aws_api_pred.append(fac_resp)
print("---AWS API Execution time: %s seconds ---" % (time.time() - start_time))


# In[277]:


aws_api_pred_f = aws_api_pred.merge(movies.loc[:,('movieId', 'title')], on='title' , how='left')
aws_api_pred_f = aws_api_pred_f.loc[:,('userId', 'movieId', 'prediction', 'title')]
aws_api_pred_f['source'] = 'AWS'
aws_api_pred_f


# # Azure API
# Below we get the recommendations from the API that we have deployed on Azure Machine Learning Studio

# In[278]:


def get_azure_pred(user_id, ratings_titles_df):
    req = ratings_titles_df.loc[ratings_titles_df.userId==user_id]
    req = req.loc[:,('userId','title','rating')]
    
    if req.empty==True:
        df_r = pd.DataFrame({user_id}, columns=['User'])
        print("\t WARNING: User", str(user_id), "does not have existing ratings; Predictions will be NaN")
        return df_r
    
    req['userId'] = req.userId.astype(str)
    req['rating'] = req.rating.astype(str)
    req = req.values.tolist()
    req_dict = { "Inputs": { "input1": { "ColumnNames": [ "userId", "title", "rating" ], "Values": req } }, "GlobalParameters": {} }
    
    url = 'https://ussouthcentral.services.azureml.net/workspaces/10666c0c4ab84aaf8c65025dcc8d9362/services/2382b18fb9094179b4da1aaa0e14a960/execute?api-version=2.0&details=true'
    # Adding empty header as parameters are being sent in payload
    headers = {"Authorization":"Bearer M3acce0G14PPaOyfwzuGC3cfRV0ZqCN3LVDJIFiBYEx+8xQAdX37vI8WJqcKck9QWf8EU97+M0K/Z+92nlGnrw==",
          "Content-Type":"application/json"
          }
    resp = requests.post(url, headers=headers, data=json.dumps(req_dict)) #headers=headers
    
    r_load = json.loads(resp.content)
    df_r = pd.DataFrame(r_load['Results']['output1']['value']['Values'][0])
    df_r = df_r.T
    df_r.columns = r_load['Results']['output1']['value']['ColumnNames']
    return df_r


# In[279]:


resp_external_api_azure_pred = pd.DataFrame(columns=['User', "Item 1", "Item 2", "Item 3","Item 4", "Item 5"])

start_time = time.time() #calculate execution time
for u in ids_list:
    print("Parsing prediction for user: ", str(u) )
    pred_az = get_azure_pred(u, ratings_titles) #input user_id and ratings file with movie titles
    resp_external_api_azure_pred = resp_external_api_azure_pred.append(pred_az)

print("---Azure API Execution time: %s seconds ---" % (time.time() - start_time))

#results  


# In[89]:


external_api_azure_pred = resp_external_api_azure_pred.melt(id_vars="User", value_name="Movie_title")
external_api_azure_pred['User'] = external_api_azure_pred['User'].astype(int)
external_api_azure_pred.columns = ['userId', 'rank', 'title']
external_api_azure_pred = external_api_azure_pred.sort_values(by=['userId', 'rank'],ascending=True)
external_api_azure_pred = external_api_azure_pred.merge(movies.loc[:,('title','movieId')], on='title' , how='left')
external_api_azure_pred['source'] = 'External-Azure'
external_api_azure_pred.head()


# # Wrap up
# Below we keep the manipulate the recommendations so to merge them in a single file

# In[282]:


internal_api_faculty_pred_concat = internal_api_faculty_pred.loc[:,('userId', 'movieId', 'source')]
internal_api_faculty_pred_concat


# In[85]:


aws_api_pred_f_concat = aws_api_pred_f.loc[:,('userId', 'movieId', 'source')]
aws_api_pred_f_concat.head()


# In[90]:


external_api_azure_pred_concat = external_api_azure_pred.loc[:,['userId', 'movieId', 'source']]
external_api_azure_pred_concat.head()


# In[296]:


sum_3apis = internal_api_faculty_pred_concat.append(aws_api_pred_f_concat).append(external_api_azure_pred_concat)
sum_3apis = sum_3apis.drop_duplicates(['userId', 'movieId'], keep='first') #removes duplicate recommendations from the different APIs
sum_3apis


# # SageMaker API
# For these user-movie pairs, we get predictions from the SageMaker that has been deployed for the needs of this project

# In[300]:


sum_3apis['rating'] = 5
sum_3apis['timestamp'] = 999
sum_3apis = sum_3apis.drop('source', axis=1)
sum_3apis


# In[101]:


"""
The following code uses the 100k movie lens example to make inference against an endpoint deployed on Sakemaker
to determine if a movie is suitable for a user in the dataset.
This example uses two of the users in test set as an example to determine a score for the movie user combination
"""

import boto3, csv, json
import numpy as np
from scipy.sparse import lil_matrix

nbUsers = 943
nbMovies = 1682

moviesByUser = {}
for userId in range(nbUsers):
    moviesByUser[str(userId)] = []

def loadDataset(filename, lines, columns):
    # Features are one-hot encoded in a sparse matrix
    X = lil_matrix((lines, columns)).astype('float32')
    # Labels are stored in a vector
    Y = []
    line = 0
    with open(filename, 'r') as f:
        samples = csv.reader(f, delimiter='\t')
        for userId, movieId, rating, timestamp in samples:
            X[line, int(userId) - 1] = 1
            X[line, int(nbUsers) + int(movieId) - 1] = 1
            if int(rating) >= 4:
                Y.append(1)
            else:
                Y.append(0)
            line = line + 1

    Y = np.array(Y).astype('float32')
    return X, Y

# this code serialises the data for use by the sagemaker API, in this case is expands the sparse matrix to a dense version
# see https://docs.aws.amazon.com/sagemaker/latest/dg/cdf-inference.html for more examples of dense ans spare formats
def fm_serializer(data):
    js = {'instances': []}
    for row in data:
        js['instances'].append({'features': row.tolist()})
    # print js
    return json.dumps(js)


# In[114]:


def sage_label(sugg_movies):
    
    nbUsers = 943
    nbMovies = 1682

    nbFeatures = nbUsers + nbMovies
    #sugg_movies = sugg_movies.loc[sugg_movies.userId==uid]

    nbRatings = sugg_movies.shape[0]
    sugg_movies.to_csv('temp.pred', sep='\t', header=False, index=False)

    X_test, Y_test = loadDataset('temp.pred', nbRatings , nbFeatures)

    data = X_test.toarray()


    payload = fm_serializer(data)

    runtime_client = boto3.client('sagemaker-runtime', region_name='eu-west-2', aws_access_key_id='AKIA4LVLLZ6RVW3YN23V',
                                  aws_secret_access_key='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')

    # the endpoint traing on the 100k dataset and deployed to AWS
    endpoint_name = 'factorization-machines-2020-03-14-18-20-08-738'
    response = runtime_client.invoke_endpoint(EndpointName=endpoint_name,
                                              ContentType='application/json',
                                              Accept='application/json',
                                              Body=payload)
    
    text = response['Body'].read().decode("utf-8")
    d = json.loads(text)
    return d['predictions']


# The results can be found below:

# In[301]:


sum_3apis['sage_score'] = pd.DataFrame(sage_label(sum_3apis))['score']
sum_3apis


# Finally we select to keep the 5 user-movie pairs with the highest score from SageMaker

# In[302]:


sum_3apis['ranking'] = sum_3apis.groupby('userId')['sage_score'].rank(method='first', ascending=False)
sum_3apis_top5 = sum_3apis.loc[sum_3apis.ranking<=5]
sum_3apis_top5 = sum_3apis_top5.sort_values(['userId', 'ranking'], ascending=True)
sum_3apis_top5 = sum_3apis_top5.loc[:,['userId', 'movieId', 'sage_score']]
sum_3apis_top5 = sum_3apis_top5.reset_index(drop=True)
sum_3apis_top5['model'] = 'final' 
#sum_3apis_top5.columns = ['userId', 'movieId', 'rating_or_ranking' , 'model']
sum_3apis_top5.head(10)


# In[303]:


#Unfortunately due to time limitations we could not provide the recommendations in the format that was requested
sum_3apis_top5.to_csv('final_recomm.csv')


# In[ ]:




