FROM ubuntu:18.04
COPY . /app
RUN apt-get update 
RUN apt-get install -y libmojolicious-perl libjson-perl
WORKDIR /app/
CMD perl /app/app.pl
