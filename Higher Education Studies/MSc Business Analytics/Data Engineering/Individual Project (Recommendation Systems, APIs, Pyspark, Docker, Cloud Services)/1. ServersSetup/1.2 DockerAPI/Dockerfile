FROM scratch

# -- ALS API image
LABEL maintainer "Symeon Kokovidis"

FROM ubuntu:18.04

RUN apt-get update
RUN apt -y install python3-pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN apt-get install -y openjdk-8-jdk python-pip
RUN apt -y install python3-pip

RUN pip install numpy==1.16.6 --no-cache-dir
RUN pip install pandas --no-cache-dir
RUN pip install Flask==1.1.2 --no-cache-dir
RUN pip install flask-restful==0.3.8 --no-cache-dir
RUN pip install pyspark --no-cache-dir

#The following command makes server to run cross_validation script every day at 04:00am
#RUN { crontab -l; echo "0 4 * * * python crossval.py"; } | crontab -

COPY . /flaskapp
WORKDIR /flaskapp

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["D. app.py"]
