#!/bin/bash

set -e -x

docker build -t wonmin82-trusty $PWD/wonmin82-trusty
docker run --detach --publish=21404:22 --hostname=wonmin82-trusty-docker --name=wonmin82-trusty-docker wonmin82-trusty
docker stop wonmin82-trusty-docker
