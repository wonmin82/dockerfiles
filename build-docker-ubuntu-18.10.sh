#! /usr/bin/env bash

set -e -x

docker build -t docker-ubuntu-18.10 $PWD/docker-ubuntu-18.10
docker run --detach --publish=21810:22 --hostname=docker-ubuntu-cosmic --name=docker-ubuntu-18.10 docker-ubuntu-18.10
docker stop docker-ubuntu-18.10
docker commit -m "Initial Ubuntu 18.10" docker-ubuntu-18.10 docker-ubuntu-18.10:initial
