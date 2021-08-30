#!/bin/bash

FUZZER=$1 # Fuzzer name (schemathesis,restler,evomaster,all)
OUTDIR=$2 # result folder in container
TIME=$3 # time for running the fuzzer
SKIPCOUNT=$4

service mysql start
service apache2 start

echo -e "SKIPCOUNT=$SKIPCOUNT\nRUNCOUNT=$SKIPCOUNT\nOUTDIR=$OUTDIR" > ./.env
sudo chmod -R a+rwx ./.env

mkdir /home/ubuntu/log/${OUTDIR}
sudo chmod -R a+rwx /home/ubuntu/log/${OUTDIR}/

if [ $FUZZER = "restler" ]; then

	## Compile and generate Restler grammar from specification
	cd restler-fuzzer/restler_bin/
	./restler/Restler compile --api_spec /home/ubuntu/webapi.json
	
	timeout -k 0 $TIME ./restler/Restler test --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
	timeout -k 0 $TIME ./restler/Restler fuzz-lean --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
	timeout -k 0 $TIME ./restler/Restler fuzz --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
	wait

elif [ $FUZZER = "schemathesis" ]; then

	## Generate Schemathesis testcases
	timeout -k 0 $TIME schemathesis run --checks all --store-network-log=output.yaml  http://localhost/webapi.json
	wait
	
elif [ $FUZZER = "evomaster" ]; then

	## Generate evoMaster testcases
	cd /home/ubuntu/
	timeout -k 0 $TIME java -jar evomaster.jar --blackBox true --bbSwaggerUrl http://localhost/webapi.json --outputFormat JAVA_JUNIT_4 --maxTime ${TIME}s
	wait

else
	
	echo "Invalid Fuzzer Name!!"
	
fi





