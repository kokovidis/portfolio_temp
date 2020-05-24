sudo yum install docker 

sudo service docker restart
sudo service docker status
sudo docker run hello-world

sudo docker pull uceisko/flaskapp:0.1

sudo setfacl -m user:$USER:rw /var/run/docker.sock #get root access to the app

sudo docker images #get image id

docker run -d -p 8080:8080 a3a04a644b09 #use the image id as last argument
