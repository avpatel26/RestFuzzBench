#!/bin/bash

#./exec_common wordpress /home/avi/Desktop/ 2 restler restler 200 5 test root root

IMAGE=$1 # Image name
RESULT=$2 # path of folder to store Final result of the test
RUNS=$3 #number of runs


FUZZER=$4 # Fuzzer name (schemathesis,restler,evomaster)
OUTDIR=$5 # result folder in container
TIME=$6 # time for running the fuzzer
SKIPCOUNT=$7
CONFIG=$8 # configuration for restler mode (fuzz,fuzzlean,test)
USERNAME=$9 # username for api authentication
PASSWORD=$10 # password for api authentication


containers_array=()
containers_list=""

for ((i=1;i<=RUNS;i++)); do
	id=$(docker run -d -it $IMAGE /bin/bash -c "cd /home/ubuntu/ && ./run.sh ${FUZZER} ${OUTDIR} ${TIME} ${SKIPCOUNT} ${CONFIG} ${USERNAME} ${PASSWORD}")
	containers_array[i]="${id::12}" 
	containers_list+=" ${containers_array[i]}"
done

printf "Fuzzing in progress.."
docker wait ${containers_list}
wait

printf "Collecting results...\n"

for ((i=1;i<=RUNS;i++)); do
	mkdir ${RESULT}/${OUTDIR}_${i}/
	docker cp ${containers_array[i]}:/home/ubuntu/covfile ${RESULT}/${OUTDIR}_${i}/ > /dev/null
done

printf "Experiment is done!! \n"

