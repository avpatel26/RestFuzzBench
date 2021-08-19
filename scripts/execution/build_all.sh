#!/bin/bash

cd $RFBENCH
cd services/wordpress
sudo docker build . -t wordpress --build-arg db_name=db --build-arg db_password=root

