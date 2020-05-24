### Group Coursework
The group coursework extends the Spotify business problem from the Individual coursework. Our aim was to deliver a report for the Data Science team of Warner Music Group. 

The main goal was to investigate the factors that have predictive power on the success of an artist. 

To achieve this, we created basis-features regarding artists, users and playlists. To extend our model, we extracted features through the Spotify API. Furthermore, we generated different combinations of features for the region and age of the streamers and reduced their dimension with the PCA.

With the best performing set of features (in terms of AUC) we created an XGBoost model which takes advantage of the kPCA for the features of region and age. Finally, we used a non-exhaustive method (RandomizedSearchCV) to find well-performing hyperparameters.



