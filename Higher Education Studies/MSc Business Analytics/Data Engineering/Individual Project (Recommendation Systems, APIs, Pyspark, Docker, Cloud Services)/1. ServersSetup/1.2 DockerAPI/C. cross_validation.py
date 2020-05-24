import os
import sys
os.environ['PYSPARK_PYTHON'] = "python3"
os.environ['PYSPARK_DRIVER_PYTHON'] = "python3" #sys.executable

import json
import numpy as np

#!pip install pyspark
import pyspark
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark import SQLContext

from pyspark.ml.tuning import CrossValidator, ParamGridBuilder, TrainValidationSplit
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.recommendation import ALS
from pyspark.sql.functions import lit
from pyspark.sql.types import IntegerType, FloatType, StringType

import time ###calculate execution time

start_time = time.time()

conf = SparkConf().set("spark.master", "local[*]").set("spark.sql.crossJoin.enabled","true")#.set("spark.driver.allowMultipleContexts","true")
sc = SparkContext( conf=conf, appName='als_predictor')
sqlContext = SQLContext(sc)



### RATINGS DATASET
##################
    ###ELSE FOR EVERY NEXT ITERATION
small_ratings_DF = sqlContext.read.csv("./GenDataCollection/ratings_upd.csv", inferSchema=True, header = True)
#remove timestaps
#small_ratings_DF = small_ratings_DF.drop('timestamp')


    #preprocessing 
#small_ratings_DF = small_ratings_DF.withColumn("userId", small_ratings_DF["userId"].cast(IntegerType()))
#small_ratings_DF = small_ratings_DF.withColumn("movieId", small_ratings_DF["movieId"].cast(IntegerType()))
#small_ratings_DF = small_ratings_DF.withColumn("rating", small_ratings_DF["rating"].cast(FloatType()))

###TRAIN-TEST SPLIT
##################
#(training, test) = small_ratings_DF.randomSplit([0.8, 0.2]) # split into test and training set
#training.printSchema() # just for testing, should show the four columns
#print(training.count())

#### TRAIN DATASET
##################
    ##Build the recommendation model using ALS on the training data
als = ALS(maxIter=3, userCol="userId", itemCol="movieId", ratingCol="rating",
         coldStartStrategy="drop") #coldStartStrategy="drop" to get valid results

paramGrid = ParamGridBuilder().addGrid(als.regParam, [0.03,0.1,0.3]).addGrid(als.rank, [3,10,30]).build()

regEval = RegressionEvaluator(metricName="rmse", labelCol="rating") #predictionCol="prediction"
crossVal = CrossValidator(estimator=als, estimatorParamMaps=paramGrid, evaluator=regEval, seed=94)
cvModel = crossVal.fit(small_ratings_DF)

#### EXTRACT BEST PARAMETERS FROM GRID SEARCH CV - SAVE THEM TO JSON
######################################################
best_dict = cvModel.getEstimatorParamMaps()[np.argmin(cvModel.avgMetrics)] #argmin get the lowest rmse 
best_dict_list = list(best_dict.values())
best_dict_list  ### [0]:regParam , [1]:rank
best_dict_res = {'regParam':best_dict_list[0], 'rank': best_dict_list[1] }

with open('./GenDataCollection/best_params.json', 'w') as f:
    json.dump(best_dict_res, f)

ex_time = str("--- Execution time : %s seconds ---" % (time.time() - start_time))
print(ex_time)

with open("./GenDataCollection/ex_time.txt", "w") as text_file:
    text_file.write(ex_time)
