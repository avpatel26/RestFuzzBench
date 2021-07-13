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

RUN sudo apt update


ADD ./jenkins.sh jenkins.sh

#Set up Fuzzers
RUN git clone https://github.com/avpatel26/restler-fuzzer.git && \
    cd restler-fuzzer && \
    mkdir restler_bin

ENV restler = "/home/ubuntu/restler-fuzzer"


