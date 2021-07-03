#!/bin/bash

##Install wordpress
sudo chmod +x wordpress.sh 
sudo ./wordpress.sh

##Delete Installed files
rm -rf latest.tar.gz wordpress

##Compile Restler

cd restler-fuzzer
python3.8 ./build-restler.py --dest_dir ./restler_bin/
dotnet nuget locals all --clear


## Compile and generate Restler grammar from specification
cd restler_bin/restler 
chmod a+x Restler
./Restler compile --api_spec home/ubuntu/webapi.json

