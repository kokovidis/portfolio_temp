import os
import sys
os.environ['PYSPARK_PYTHON'] = "python3" #requirement for faculty.ai
os.environ['PYSPARK_DRIVER_PYTHON'] = "python3" 
from flask import Flask
from flask import request

import pandas as pd
import pickle
import json
from collections import defaultdict

flask_server = Flask(__name__)

with open('top_10_recomm.pkl', 'rb') as f:  #we load the recommendations
    top_10 = pickle.load(f)
    
@flask_server.route('/predict/<int:uid>', methods=['GET'])  #we define our get endpoint
def get_top_10(uid):
    if not top_10[uid]:
        empty = pd.DataFrame(columns=['movieId' , 'pred_rating', 'userId'])
        empty.loc[0,'userId']=uid
        empty_json = empty.to_json()
        return empty_json
    else:
        extr = top_10[uid]
        extr = pd.DataFrame(extr)
        extr['user_id'] = uid
        extr.columns = ['movieId' , 'pred_rating', 'userId']
        resp_json = extr.to_json()
        return resp_json
    
if __name__ == '__main_':
    logging.info('Listening on port {}'.format(8080))
    flask_server.run(debug=True, host='0.0.0.0', port=8080, threaded=False)  #(debug=False, host='127.0.0.1', port=8080,  threaded=False) 