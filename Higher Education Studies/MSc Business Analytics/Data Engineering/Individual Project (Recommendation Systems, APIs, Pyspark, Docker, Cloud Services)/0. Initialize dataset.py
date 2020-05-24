#!/usr/bin/env python
# coding: utf-8

# # Initialize Dataset
# This script converts the u.data file and u.item to the .csv files that we are going to use through this project:

import pandas as pd



#save u.data file as csv. It is the ratings reference dataset throughout the whole project
udata = pd.read_csv('/project/DataCollection/u.data', delimiter='\t', header=None )
udata.columns= ['userId','movieId','rating','timestamp']
udata = udata.sort_values(['userId', 'movieId'])
udata.to_csv('ratings.csv', index=False)






