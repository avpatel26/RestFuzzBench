#!/bin/bash

#./exec_common wordpress /home/avi/Desktop/ 2 evomaster evomaster 400 5

IMAGE=$1 # Image name
RESULT=$2 # path of folder to store Final result of the test
RUNS=$3 #number of runs


FUZZER=$4 # Fuzzer name (schemathesis,restler,evomaster)
OUTDIR=$5 # result folder in container
TIME=$6 # time for running the fuzzer
SKIPCOUNT=$7

containers_array=()
containers_list=""

for ((i=1;i<=RUNS;i++)); do
	id=$(docker run -d -it $IMAGE /bin/bash -c "cd /home/ubuntu/ && ./run.sh ${FUZZER} ${OUTDIR} ${TIME} ${SKIPCOUNT}")
	containers_array[i]="${id::12}" 
	containers_list+=" ${containers_array[i]}"
done

printf "Fuzzing in progress.."
docker wait ${containers_list}
wait

printf "Collecting results...\n"

for ((i=1;i<=RUNS;i++)); do
	docker cp ${containers_array[i]}:/home/ubuntu/log/${OUTDIR}/ ${RESULT}/${OUTDIR}_${i}/ > /dev/null
done

printf "Experiment is done!! \n"

printf "Merging and generating report of code coverage for experiment"

wget https://phar.phpunit.de/phpcov.phar

for ((i=1;i<=RUNS;i++)); do
	php phpcov.phar merge --html ${RESULT}/${OUTDIR}_${i}/ ${RESULT}/${OUTDIR}_${i}/
done

rm ./phpcov.phar
