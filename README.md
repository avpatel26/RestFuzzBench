# RestFuzzBench
RestFuzzBench: A benchmark for REST API Fuzzing

# Setup of RESTFuzzBench

## 1st step: Clone and Checkout the develop branch
```
git clone https://github.com/avpatel26/RestFuzzBench.git
cd RestFuzzBench/
git checkout develop
```

## 2nd step: Build a docker image

```
cd services/wordpress/
sudo docker build . -t wordpress
```

## 3rd step: Run docker container and Fuzzer

```
sudo docker run -it wordpress
```

## 4th step: Run following commands in Docker Interface

run.sh file contains script for wordpress and restler setup within a container

```
sudo chmod +x run.sh
sudo ./run.sh
```







