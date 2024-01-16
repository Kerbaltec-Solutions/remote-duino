#!/bin/bash
docker start python_container
docker start nginx_container
read -s -n 1
docker stop python_container
docker stop nginx_container
exit 0