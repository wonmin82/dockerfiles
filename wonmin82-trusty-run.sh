#!/bin/bash

set -e -x

docker run --detach --publish=20022:22 --hostname=wonmin82-trusty-docker --name=wonmin82-trusty-docker wonmin82-trusty
