#!/bin/bash

FUZZER=$1 # Fuzzer name (schemathesis,restler,evomaster,all)
OUTDIR=$2 # result folder in container
TIME=$3 # time for running the fuzzer

if [$FUZZER = "restler"]; then

	## Compile and generate Restler grammar from specification
	cd restler-fuzzer/restler_bin/
	./restler/Restler compile --api_spec /home/ubuntu/webapi.json
	./restler/Restler test --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
	./restler/Restler fuzz-lean --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
	./restler/Restler fuzz --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl

elif [$FUZZER = "schemathesis"]; then

	## Generate Schemathesis testcases
	schemathesis run --checks all --store-network-log=output.yaml  http://localhost/webapi.json

elif [$FUZZER = "evomaster"]; then

	## Generate evoMaster testcases
	cd /home/ubuntu/
	java -jar evomaster.jar --blackBox true --bbSwaggerUrl http://localhost/webapi.json --outputFormat JAVA_JUNIT_4 --maxTime 30s

else
	
	
fi

