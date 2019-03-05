#!/bin/bash

set -e -x

docker build -t docker-ubuntu-18.04 $PWD/docker-ubuntu-18.04
docker run --detach --publish=21804:22 --hostname=docker-ubuntu-bionic --name=docker-ubuntu-18.04 docker-ubuntu-18.04
docker stop docker-ubuntu-18.04

