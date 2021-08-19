#!/bin/bash

#./exec_common wordpress /home/avi/ 2 all /home/ubuntu/log/ 5

IMAGE=$1 # Image name
RESULT=$2 # path of folder to store Final result of the test
RUNS=$3 #number of runs


FUZZER=$4 # Fuzzer name (schemathesis,restler,evomaster,all)
OUTDIR=$5 # result folder in container
TIME=$6 # time for running the fuzzer

containers_array=()
containers_list=""

for ((i=1;i<=RUNS;i++)); do
	id=$(docker run -d -it $IMAGE /bin/bash -c "cd /home/ubuntu/ && run ${FUZZER} ${OUTDIR} ${TIME}")
	containers_array[i]="${id::12}" 
	containers_list+=" ${containers_array[i]}"
done

docker wait ${containers_list}
wait


