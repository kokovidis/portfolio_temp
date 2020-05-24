### Individual Coursework
In this project we built a data pipeline to support elements of a Recommender System for movies. We developed three predictive models that were deployed as REST APIs. 

The first was developed in the Faculty.ai Data Science Platform.For selecting our predictive model we used the [Surpise](http://surpriselib.com/) (a Python  recommender systems package) with the use of [MLflow](https://mlflow.org/) (a platform for Machine Learning lifecycle). After the experimentation with different algorithms we used for our final model the Singular Value Decomposition (SVD) algorithm. 

The second API was developed in a Google Cloud Virtual Machine and has used the Alternating Least Square (ALS) Matrix Factorization algorithm. For the creation of this model, PySpark package (Python package for [Apache Spark](http://spark.apache.org/)) has been used. After the successful deployment of the API, we pushed our environment to a repo on Docker Hub. The same container was tested on the Amazon Web Services.

Finally, for our third API we exploited the Azure Machine Learning Studio and the [Matchbox Algorithm](https://www.microsoft.com/en-us/research/publication/matchbox-large-scale-bayesian-recommendations/) which was developed by Microsoft. 

From these three APIs we fetched movie recommendations for ourtest-users. Finally, for these user-movie pairs we requested likelihood scores from an [Amazon SageMaker](https://aws.amazon.com/sagemaker/) API that was developed from the teaching team for the needs of this project. Based on the best scores, we provided five movie recommendations to our test-users.