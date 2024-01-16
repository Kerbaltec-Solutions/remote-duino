#!/bin/bash
#docker stop python_container || true && docker rm python_container || true
docker stop nginx_container || true && docker rm nginx_container || true
docker volume rm rduinoshared || true
docker volume create --name rduinoshared
#docker build -t python-script-container -f Dockerfile.python .
docker build -t nginx-container:dev . -f Dockerfile.nginx
#docker run --name python_container -p 5000:5000 -v rduinoshared:/rshared python-script-container &
docker run --name nginx_container -p 80:80 -v rduinoshared:/rshared nginx-container:dev &
read -s -n 1
#docker stop python_container
docker stop nginx_container
exit 0
