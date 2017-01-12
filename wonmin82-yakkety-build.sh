#!/bin/bash

set -e -x

docker build -t wonmin82-yakkety $PWD/wonmin82-yakkety
docker run --detach --publish=30022:22 --hostname=wonmin82-yakkety-docker --name=wonmin82-yakkety-docker wonmin82-yakkety
docker stop wonmin82-yakkety-docker
