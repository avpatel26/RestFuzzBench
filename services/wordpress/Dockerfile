# Install Dependency for Restler Fuzzer
FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y install sudo \
    apt-utils \
    build-essential \
    openssl \
    clang \
    git \
    python-pip \
    nano \
    net-tools \
    vim

RUN apt-get install wget
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN sudo dpkg -i packages-microsoft-prod.deb
RUN sudo apt-get update; 
RUN sudo apt-get install -y apt-transport-https
RUN  sudo apt-get update 
RUN  sudo apt-get install -y dotnet-sdk-5.0

RUN apt-get -y install python3.8


#Set up Fuzzers
RUN git clone https://github.com/avpatel26/restler-fuzzer.git && \
    cd restler-fuzzer && \
    mkdir restler_bin

