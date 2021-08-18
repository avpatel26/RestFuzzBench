#!/bin/bash

## Compile and generate Restler grammar from specification
cd restler-fuzzer/restler_bin/
./restler/Restler compile --api_spec /home/ubuntu/webapi.json
./restler/Restler test --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
./restler/Restler fuzz-lean --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl
./restler/Restler fuzz --grammar_file ./Compile/grammar.py --dictionary_file ./Compile/dict.json --no_ssl



## Generate evoMaster testcases
cd /home/ubuntu/
java -jar evomaster.jar --blackBox true --bbSwaggerUrl http://localhost/webapi.json --outputFormat JAVA_JUNIT_4 --maxTime 30s


## Generate Schemathesis testcases
schemathesis run --checks all --store-network-log=output.yaml  http://localhost/webapi.json
