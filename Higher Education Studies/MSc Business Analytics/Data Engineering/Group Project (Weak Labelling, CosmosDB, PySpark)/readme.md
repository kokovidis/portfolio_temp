# Group Coursework

The goal of this project was to use the [Snorkel](https://www.snorkel.org/) generative approach to produce a set of weak labels for restaurant reviews from the [Yelp dataset](https://www.yelp.com/dataset). In more detail, to create a new label for each review which indicates if the it was related with recommendations or complaints for the restaurant.

In order to accomplish this objective we developed a set of labeling functions that can be combined to generate the aforementioned label.

Within the same project, we deployed also a NoSQL database on Microsoft Azure ([CosmosDB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction)) and we accessed information for the registered businesses on Yelp.

The whole project was developed in [Apache Spark](http://spark.apache.org/) with the use of PySpark package for Python. 
