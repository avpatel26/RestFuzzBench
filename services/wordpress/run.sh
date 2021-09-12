#!/bin/bash

# ./run.sh restler restler 200 5 test root root

FUZZER=$1 # Fuzzer name (schemathesis,restler,evomaster,all)
OUTDIR=$2 # result folder in container
TIME=$3 # time for running the fuzzer
SKIPCOUNT=$4
CONFIG=$5
USERNAME=$6
PASSWORD=$7


service mysql start
wait
service apache2 start
wait

echo -e "SKIPCOUNT=$SKIPCOUNT\nRUNCOUNT=$SKIPCOUNT\nOUTDIR=$OUTDIR" > ./.env
sudo chmod -R a+rwx ./.env

mkdir /home/ubuntu/log/${OUTDIR}
sudo chmod -R a+rwx /home/ubuntu/log/${OUTDIR}/

if [ $FUZZER = "restler" ]; then

	## Compile and generate Restler grammar from specification
	cd restler-fuzzer/restler_bin/
	./restler/Restler compile --api_spec /home/ubuntu/webapi.json
 	RTIME=$(awk "BEGIN {printf \"%.5f\",${TIME}/3600}")
	if [[ $CONFIG = "test" || $CONFIG = "fuzz-lean" || $CONFIG = "fuzz" ]]; then
		./restler/Restler $CONFIG --grammar_file ./Compile/grammar.py \
					   --dictionary_file ./Compile/dict.json \
					   --no_ssl \
					   --time_budget $RTIME \
					   --token_refresh_command "python3 /home/ubuntu/token.py ${USERNAME} ${PASSWORD}" \
					   --token_refresh_interval $TIME  
		wait
	else
		echo "Invalid configuration!!"
	fi

elif [ $FUZZER = "schemathesis" ]; then

	## Generate Schemathesis testcases
	timeout -k 0 $TIME schemathesis run --checks all --auth $USERNAME:$PASSWORD  http://localhost/webapi.json
	wait
	
elif [ $FUZZER = "evomaster" ]; then

	## Generate evoMaster testcases
	cd /home/ubuntu/
	timeout -k 0 $TIME java -jar evomaster.jar --blackBox true --bbSwaggerUrl http://localhost/webapi.json --outputFormat JAVA_JUNIT_4 --maxTime ${TIME}s
	wait

else
	
	echo "Invalid Fuzzer Name!!"
	
fi





