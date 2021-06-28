#!/bin/bash

IMAGE=$1
RESULT=$2
FUZZER=$3
OUTDIR=$4

id = $(docker run -d -it $IMAGE /bin/bash -c "cd ${WORKDIR} && run ${FUZZER} ${OUTDIR}")

docker cp ${id}:/home/ubuntu/experiments/${OUTDIR}.tar.gz ${RESULT}/${OUTDIR}.tar.gz > /dev/null