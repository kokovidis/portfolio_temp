import os
import sys
#os.environ['PYSPARK_PYTHON'] = "python3"  #ENABLE WHEN IN FACULTY
#os.environ['PYSPARK_DRIVER_PYTHON'] = "python3" #sys.executable

from flask import Flask
from flask_restful import reqparse, abort, Api, Resource

from flask import Flask
from flask import request
import json
import pandas as pd

#install spark
#!pip install pyspark
import pyspark
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark import SQLContext

from pyspark.ml.tuning import CrossValidator, ParamGridBuilder, TrainValidationSplit
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.recommendation import ALS
from pyspark.sql.functions import lit, col
from pyspark.sql.types import IntegerType, FloatType, StringType, ByteType


import numpy as np
import json

# create a Flask instance
# and create a Flask-RESTful API instance with the created Flask instance
app = Flask(__name__)
api = Api(app)

# create a SparkContext
# load saved pipeline model from the folder 'model'

conf = SparkConf().set("spark.sql.crossJoin.enabled","true")#.set("spark.master", "local[*]").set("spark.driver.allowMultipleContexts","true")
sc = SparkContext('local[*]', conf=conf, appName='als_predictor')
sqlContext = SQLContext(sc)

# create a parser
# fill a parser with information about arguments 
parser = reqparse.RequestParser()
parser.add_argument('query', type=dict)





###MOVIES DATASET
##################
small_movies_data_DF =sqlContext.read.csv("./GenDataCollection/movies_upd.csv", inferSchema=True)
small_movies_data_DF = small_movies_data_DF.select(col("_c0").alias("movieId"), col("_c1").alias("title"))
small_movies_data_DF = small_movies_data_DF.withColumn("movieId", small_movies_data_DF["movieId"].cast(IntegerType()))
#small_movies_data_DF.show(5)

### RATINGS DATASET
##################
    #load    
small_ratings_DF = sqlContext.read.csv("./GenDataCollection/ratings_upd.csv" )
    #remove timestaps
small_ratings_DF = small_ratings_DF.drop('timestamp')    

small_ratings_DF = small_ratings_DF.select(col("_c0").alias("userId"), col("_c1").alias("movieId"), col("_c2").alias("rating"))
small_ratings_DF = small_ratings_DF.withColumn("userId", small_ratings_DF["userId"].cast(ByteType()))
small_ratings_DF = small_ratings_DF.withColumn("movieId", small_ratings_DF["movieId"].cast(ByteType()))
small_ratings_DF = small_ratings_DF.withColumn("rating", small_ratings_DF["rating"].cast(ByteType()))
small_ratings_DF = small_ratings_DF.na.drop(subset=["userId"])
small_ratings_DF = small_ratings_DF.na.drop(subset=["movieId"])




#Get the total ratings for each movie 
####################################
#will be used to return prediction with high number (count) of existing reviews
rati_count = small_ratings_DF.groupBy('movieId').count()
rati_count = rati_count.withColumnRenamed("count", "TotalReviews")
#rati_count.show(5)

                            ###### DEALING WITH THE NEW POST REQUEST #####
                            ##############################################


class PredictRatings(Resource):
    def post(self):
        global als_m
        global new_user_unrated_movies_DF
        global small_ratings_DF
        global small_ratings_DF_upd
        global model_tr
        global new_user_unrated_movies_DF
        global new_user_recommendations_DF
        
        ### Load request
        content = request.get_json(force=True)
        df = pd.DataFrame.from_dict(content)
        sp_df = sqlContext.createDataFrame(df)
        
        ### Load best hyper-parameters
        with open('./GenDataCollection/best_params.json') as f:
            import_param = json.load(f)
        
        ### CREATE AN EMPTY MODEL WITH THE BEST hyPARAMS
        
        als = ALS(maxIter=3, regParam=import_param['regParam'], rank=import_param['rank'], userCol="userId", itemCol="movieId", ratingCol="rating",
             coldStartStrategy="drop")
        
        ###GET PARSED USER ID
        new_user_ID = sp_df.first().userId
        ### UPDATE THE EXISTING TABLE WITH THE NEW RATINGS
        small_ratings_DF_upd = small_ratings_DF.union(sp_df)
        
        ### CREATE A LIST WITH MOVIE_IDS THAT THE USER HAS RATED
        sp_df_rated = sp_df.select('movieId').rdd.map(list).map(lambda x: x[0])
        sp_df_rated_list = sp_df_rated.collect()
        
        ### CREATE A DF WITH THE MOVIES THAT THE USER HAS NOT RATED (ALL MOVIES - RATED MOVIES)
        new_user_unrated_movies_DF = small_movies_data_DF.filter(~small_movies_data_DF.movieId.isin(sp_df_rated_list))
        #.map(lambda x: (new_user_ID, x[0]))
        #.map(lambda x: (198, x[0])))
        
        ###Sanity Checks
        #small_movies_data_DF.count()
        
            ###Preprocessing
        new_user_unrated_movies_DF = new_user_unrated_movies_DF.drop('title')
        new_user_unrated_movies_DF = new_user_unrated_movies_DF.withColumn('userId', lit(new_user_ID))
        new_user_unrated_movies_DF = new_user_unrated_movies_DF.select('userId', 'movieId') #re-arrange columns 
        
        #### TRAIN THE MODEL WITH ALL THE PREVIOUS RATINGS + NEW RECEIVED RATINGS
        model = als.fit(small_ratings_DF_upd)
        
        ### PREDICT
        #use the model to predict ratings for the rest movies of the user
        new_user_recommendations_DF = model.transform(new_user_unrated_movies_DF)
        
        #get the total number of pre-existing reviews for each movie
        new_user_recommendations_DF = new_user_recommendations_DF.join(rati_count, new_user_recommendations_DF.movieId == rati_count.movieId).drop(rati_count.movieId)
        
        #order by the highest rated predictions
        new_user_recommendations_DF = new_user_recommendations_DF.orderBy(new_user_recommendations_DF.prediction.desc())
        
        #filter out movies with less than 30 reviews
        new_user_recommendations_DF = new_user_recommendations_DF.filter(new_user_recommendations_DF.TotalReviews>30) #(returns around 10%)
        
        resp = new_user_recommendations_DF.na.drop(subset=["prediction"])
        resp = resp.limit(20)
        
        #get movie title
        resp = resp.join(small_movies_data_DF, resp.movieId == small_movies_data_DF.movieId).drop(small_movies_data_DF.movieId)
        resp = resp.select('userId', 'title', 'prediction')
        resp = resp.orderBy(resp.prediction.desc())
        
        #### CONVERT PYSPARK DF--> PANDAS DF --> DICT --> JSON RESPONSE
        resp_pd = resp.toPandas()
        resp_json = resp_pd.to_json()
        
        ### Write the new ratings to the parquet file (update existing ones)
        small_ratings_DF_upd.repartition(1).write.csv(path="./GenDataCollection/ratings_upd.csv", mode="append", header = True)
        #small_ratings_DF_upd.write.parquet("ratings_upd.parquet", mode='append')
            
        return resp_json
        
# Setup the Api resource routing
# Route the URL to the resource
api.add_resource(PredictRatings, '/')


if __name__ == '__main__':
    # run the Flask RESTful API, make the server publicly available (host='0.0.0.0') on port 8080
    app.run(host='0.0.0.0', port=8080, debug=True, threaded=False)
