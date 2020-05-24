#Predictive Analytics

The module covered the following topics:

* End-to-end Machine Learning Pipeline
* Supervised Learning (Classification, Regression)
* Unsupervised Learning (Clustering, Decomposition)
* Convolutional Neural Networks
* Recurrent Neural Networks
* Generative Adversarial Networks
* Machine Learning in production

### Individual Coursework
In the individual coursework we demonstrate a complete Machine Learning Pipeline with transactional data from Spotify Streaming Service. The final goal was to predict if an artist will become succesful in the future based on some criteria.

The project among others, it covers the steps of sanity checking (validation of the dataset), feature engineering, dimensionality reduction (PCA & kPCA) and imputation. 

For the development of the predictive model, different combinations of Machine Learning models and dimensionality reduction methods are assesed. 

Finally, high importance is given to the business value that come out of this project.

### Group Coursework
The group coursework extends the Spotify business problem. Our aim was to deliver a report for the Data Science team of Warner Music Group. 

The main goal was to investigate the factors that have predictive power on the success of an artist. 

To achieve this, we created basis-features regarding artists, users and playlists. To extend our model, we extracted features through the Spotify API. Furthermore, we generated different combinations of features for the region and age of the streamers and reduced their dimension with the PCA.

With the best performing set of features (in terms of AUC) we created an XGBoost model which takes advantage of the kPCA for the features of region and age. Finally, we used a non-exhaustive method (RandomizedSearchCV) to find well-performing hyperparameters.



