#!/bin/bash

sudo apt install python3
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2

##Install wordpress
sudo chmod +x wordpress.sh
sudo ./wordpress.sh

##Delete Installed files
rm -rf latest.tar.gz wordpress

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
sudo apt-get install python3.8-dev -y
sudo apt-get install libpython3.8-dev -y
pip3 install schemathesis
schemathesis run --checks all --store-network-log=output.yaml  http://localhost/webapi.json
