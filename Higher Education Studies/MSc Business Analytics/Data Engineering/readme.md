#Data Engineering

The module covered three major areas:

* Distributed Computing Systems Theory
* Data and Processing Fundamentals
* Practical Tools and Techniques


For the first two major areas (Distributed Computing Systems Theory & Data and Processing Fundamentals) the  covered topics were the following:

* Database Fundamentals
* Apache Hadoop (Map Reduce processing) & Spark
* Distributed Computing (scalability, reliability and achieving consensus)
* Scaling principles including horizontal and vertical scaling
* Distributed Architectures (centralised, decentralised)
* Large scale data storage strategies
* Data Processing with Pipelines
* DataOps
* Streaming architectures
* Recommender Systems
* Machine Learning in production
* Cloud Environments
* Software development and testing

For the third major area (Practical Tools and Techniques), several workshops covered the following:

* Linux and scripting introduction (Unix Shell & bash)
* Git (Version Control)
* SQL
* PySpark
* Snorkel Dry Bell (Weak Labelling)
* Docker
* Flask (API deployment in Python)
* MLflow Python Package
* Google Cloud Platform services
* Amazon Web Services
* Apache Airflow
* Apache Kafka
* Data quality testing

### Individual Coursework
In this project we built a data pipeline to support elements of a Recommender System for movies. We developed three predictive models that were deployed as REST APIs. 

The first was developed in the Faculty.ai Data Science Platform.For selecting our predictive model we used the [Surpise](http://surpriselib.com/) (a Python  recommender systems package) with the use of [MLflow](https://mlflow.org/) (a platform for Machine Learning lifecycle). After the experimentation with different algorithms we used for our final model the Singular Value Decomposition (SVD) algorithm. 

The second API was developed in a Google Cloud Virtual Machine and has used the Alternating Least Square (ALS) Matrix Factorization algorithm. For the creation of this model, PySpark package (Python package for [Apache Spark](http://spark.apache.org/)) has been used. After the successful deployment of the API, we pushed our environment to a repo on Docker Hub. The same container was tested on the Amazon Web Services.

Finally, for our third API we exploited the Azure Machine Learning Studio and the [Matchbox Algorithm](https://www.microsoft.com/en-us/research/publication/matchbox-large-scale-bayesian-recommendations/) which was developed by Microsoft. 

From these three APIs we fetched movie recommendations for ourtest-users. Finally, for these user-movie pairs we requested likelihood scores from an [Amazon SageMaker](https://aws.amazon.com/sagemaker/) API that was developed from the teaching team for the needs of this project. Based on the best scores, we provided five movie recommendations to our test-users.

### Group Coursework
The goal of this project was to use the [Snorkel](https://www.snorkel.org/) generative approach to produce a set of weak labels for restaurant reviews from the [Yelp dataset](https://www.yelp.com/dataset). In more detail, to create a new label for each review which indicates if the it was related with recommendations or complaints for the restaurant.

In order to accomplish this objective we developed a set of labeling functions that can be combined to generate the aforementioned label.

Within the same project, we deployed also a NoSQL database on Microsoft Azure ([CosmosDB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction)) and we accessed information for the registered businesses on Yelp.

The whole project was developed in [Apache Spark](http://spark.apache.org/) with the use of PySpark package for Python. 


