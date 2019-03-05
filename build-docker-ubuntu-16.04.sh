#!/bin/bash

set -e -x

docker build -t docker-ubuntu-16.04 $PWD/docker-ubuntu-16.04
docker run --detach --publish=21604:22 --hostname=docker-ubuntu-16.04 --name=docker-ubuntu-16.04 ubuntu-16.04
docker stop docker-ubuntu-16.04
