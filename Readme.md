# Accounting System How To

This is short installation guide to run Accounting system

## Installation

This instruction will describe steps to run this test application on Ubuntu 18.04
You should have docker daemon installed and running.
All commands should be executed from root user.

## Extract files from zip file into new directory, for example /tmp/test

```bash
mkdir /tmp/test
cp test_task_ilesik_docker_mvc.zip /tmp/test/
cd /tmp/test/
unzip ./test_task_ilesik_docker_mvc.zip
```

## Build docker image

```bash
docker build -t testapp:v1 -f ./dockerfiles/Dockerfile  ./app
```

After succesfull image build you should see image is in list when running command:

```bash
docker images
```

## Run the container, with publishing port 8080

```bash
docker run --publish 8080:8080 testapp:v1
```

## Done
Open your browser and point it to http://127.0.0.1:8080