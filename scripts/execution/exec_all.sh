#!/bin/bash

export TARGET=$1
export FUZZER=$2

cd $RFBENCH
mkdir results
exec_common.sh wordpress results restler out_wordpress