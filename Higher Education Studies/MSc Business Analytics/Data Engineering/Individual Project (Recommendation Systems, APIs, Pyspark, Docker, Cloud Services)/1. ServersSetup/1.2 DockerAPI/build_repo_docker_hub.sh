#build image
docker build -t uceisko_flask:latest .

#login to docker hub
docker login

#create new repo
docker tag uceisko_flask:latest uceisko/flaskapp:0.1

#push image
docker push uceisko/flaskapp:0.1
