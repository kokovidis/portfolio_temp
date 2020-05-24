#! /bin/bash
#update the package list
sudo apt-get update
#instal jdk
sudo apt-get install -y openjdk-8-jdk python-pip
#install packages
update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo apt -y install python3-pip

#pip install pandas Flask==1.1.2 pyspark --no-cache-dir flask-restful==0.3.8 numpy==1.16.6

#pyspark==2.4.4 --no-cache-dir 

pip install numpy==1.16.6 --no-cache-dir pandas --no-cache-dir Flask==1.1.2 --no-cache-dir  flask-restful==0.3.8 --no-cache-dir pyspark --no-cache-dir 
#https://stackoverflow.com/a/57490475/13030358 --no-cache-dir good for docker image

sudo apt-get install nano