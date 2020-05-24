#!pip install pyspark
import pyspark
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql.types import StringType
from pyspark import SQLContext

from pyspark.sql.types import IntegerType, FloatType

# Get a spark context

conf = SparkConf().setAppName('extract_csv')
sc = SparkContext(conf=conf)
sqlContext = SQLContext(sc)

### RATINGS DATASET 
###################
small_ratings_DF = sqlContext.read.csv("../../DataCollection/ratings.csv", inferSchema=True, header = True)
    #remove query users! (those who are requested to retrieve recommendations from the assignment)
small_ratings_DF = small_ratings_DF.filter(~small_ratings_DF.userId.isin([198,11,314,184,163,710,881,504,267,653]))
    #remove timestaps
small_ratings_DF = small_ratings_DF.drop('timestamp') 

#preprocessing 
small_ratings_DF = small_ratings_DF.withColumn("userId", small_ratings_DF["userId"].cast(IntegerType()))
small_ratings_DF = small_ratings_DF.withColumn("movieId", small_ratings_DF["movieId"].cast(IntegerType()))
small_ratings_DF = small_ratings_DF.withColumn("rating", small_ratings_DF["rating"].cast(FloatType()))

###UPDATE THE RATINGS FILE
small_ratings_DF.write.csv(path="./GenDataCollection/ratings_upd.csv", mode="append", header = True)


### MOVIE DATASET (we just extract the file to our directory)
####################
movies_DF = sqlContext.read.csv("../../DataCollection/movies.csv", inferSchema=True, header = True)
movies_DF.repartition(1).write.csv(path="./GenDataCollection/movies_upd.csv", mode="append", header = True)
