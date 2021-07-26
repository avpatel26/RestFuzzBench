# Install Dependency for Restler Fuzzer
FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y install sudo \
    apt-utils \
    build-essential \
    openssl \
    clang \
    git \
    python3-pip \
    nano \
    net-tools \
    vim \
    curl 

RUN apt-get install wget
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN sudo dpkg -i packages-microsoft-prod.deb
RUN sudo apt-get update; 
RUN sudo apt-get install -y apt-transport-https
RUN  sudo apt-get update 
RUN  sudo apt-get install -y dotnet-sdk-5.0

RUN sudo apt-get -y install python3.8

RUN sudo apt-get update
RUN sudo apt install default-jdk -y

WORKDIR /home/ubuntu

#clone RestFuzzBench
ADD  ./run.sh run.sh
ADD ./wordpress.sh wordpress.sh
ADD  ./webapi.json webapi.json
ADD ./.htaccess .htaccess

#Set up Restler
RUN git clone https://github.com/microsoft/restler-fuzzer.git && \
    cd restler-fuzzer && \
    mkdir restler_bin && \
    python3.8 ./build-restler.py --dest_dir ./restler_bin/ && \
    dotnet nuget locals all --clear

#Set up EvoMaster
RUN sudo apt-get update
RUN sudo apt install unzip
RUN wget https://github.com/EMResearch/EvoMaster/releases/download/v1.2.1/evomaster.jar.zip
RUN unzip evomaster.jar.zip 
RUN rm evomaster.jar.zip

