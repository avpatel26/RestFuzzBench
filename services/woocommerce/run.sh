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
if ! pgrep -q mysql; then
        service mysql start
fi
service apache2 start
wait

echo -e "SKIPCOUNT=$SKIPCOUNT\nRUNCOUNT=$SKIPCOUNT\nOUTDIR=$OUTDIR\nFUZZER=$FUZZER" > ./.env
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
					   --token_refresh_command "python3 /home/ubuntu/authtoken.py ${USERNAME} ${PASSWORD}" \
					   --token_refresh_interval $TIME  
		wait
	else
		echo "Invalid configuration!!"
	fi

elif [ $FUZZER = "schemathesis" ]; then

	## Generate Schemathesis testcases
	COUNT=$((TIME/199))
	timeout -k 0 $TIME schemathesis run --checks all --auth $USERNAME:$PASSWORD --store-network-log=./output.yaml  http://localhost/webapi.json --validate-schema=false --hypothesis-max-examples=$COUNT
	wait
	
elif [ $FUZZER = "evomaster" ]; then

	## Generate evoMaster testcases
	cd /home/ubuntu/
	timeout -k 0 $TIME java -jar evomaster.jar --blackBox true --bbSwaggerUrl http://localhost/webapi.json --outputFormat JAVA_JUNIT_4 --maxTime ${TIME}s
	wait

else
	
	echo "Invalid Fuzzer Name!!"
	
fi

mkdir /home/ubuntu/accesslogs
cd /var/log/apache2/
find . -name 'access*' -exec mv {} /home/ubuntu/accesslogs \;

cd /home/ubuntu/
sudo sed -e '/^[^;]*auto_prepend_file/s/=.*$/=\/home\/ubuntu\/code_coverage.php/' -i.bak /etc/php/7.4/apache2/php.ini
echo "time,l_per,l_abs,b_per,b_abs" >> covfile
sudo chmod -R a+rwx ./covfile
service apache2 restart

if [ $FUZZER = "restler" ]; then

	## Replay access.log for  coverage
        python3 ./log-replay.py ${USERNAME} ${PASSWORD}

elif [ $FUZZER = "schemathesis" ]; then

        ## Replay Schemathesis for coverage
        schemathesis replay output.yaml
        wait
elif [ $FUZZER = "evomaster" ]; then

        ## Replay access.log for coverage
        python3 ./log-replay.py ${USERNAME} ${PASSWORD}

else
        
        echo "Invalid Fuzzer Name!!"

fi




