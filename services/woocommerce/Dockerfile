# Install Dependency for RestFuzzBench
FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG db_name=db
ARG db_password=root

RUN apt-get -y update && \
    apt-get -y install sudo --no-install-recommends \
    apt-utils \
    build-essential \
    openssl \
    clang \
    git \
    python3-pip \
    python \
    nano \
    net-tools \
    vim \
    curl \
    wget \
    ca-certificates\
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu60 \
    libssl1.1 \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*
    
# Install dotnet packages for Restler 
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin -Channel 5.0 -InstallDir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install wordpress dependencies
RUN sudo apt-get update && \
    sudo apt install default-jdk -y && \
    sudo apt-get install apache2 apache2-utils -y && \
    sudo apt install mysql-server mysql-client -y && \
    sudo apt install rsync grsync -y

## Install PHP
ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sudo apt install software-properties-common -y && \
    sudo add-apt-repository ppa:ondrej/php && \
    sudo apt update &&\
    sudo apt install php7.4 libapache2-mod-php7.4 php7.4-mysql -y  

WORKDIR /home/ubuntu
RUN sudo apt-get -y install python3.8

#clone RestFuzzBench files
ADD ./run.sh run.sh
ADD ./woocommerce.sh woocommerce.sh
ADD ./webapi.json webapi.json
ADD ./.htaccess .htaccess
ADD ./code_coverage.php code_coverage.php
ADD ./authtoken.py authtoken.py
ADD ./log-replay.py log-replay.py

# Wordpress setup
RUN chmod +x woocommerce.sh && \
    ./woocommerce.sh $db_name $db_password && \
    rm ./woocommerce.sh

RUN service apache2 restart
RUN service mysql restart

#Set up Restler
RUN git clone https://github.com/microsoft/restler-fuzzer.git && \
    cd restler-fuzzer && \
    mkdir restler_bin && \
    python3.8 ./build-restler.py --dest_dir ./restler_bin/ && \
    dotnet nuget locals all --clear

#Set up EvoMaster
RUN sudo apt-get update && \
    sudo apt install unzip && \
    wget https://github.com/EMResearch/EvoMaster/releases/download/v1.2.1/evomaster.jar.zip && \
    unzip evomaster.jar.zip && \ 
    rm evomaster.jar.zip 

# Set up of Schemathesis
RUN sudo apt install python3 && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 && \
    sudo apt-get install python3.8-dev -y && \
    sudo apt-get install libpython3.8-dev -y && \
    sudo apt-get install python3-setuptools -y && \
    pip3 install schemathesis

# Set up of code coverage tool
RUN sudo apt install php7.4-dev php7.4-xml -y && \
    pecl install xdebug &&\
    sudo echo -e "zend_extension=xdebug;\n xdebug.mode = coverage; \nxdebug.client_host=127.0.0.1; \nxdebug.client_port=80;" >> /etc/php/7.4/apache2/php.ini && \
    sudo sed -e '/^[^;]*memory_limit/s/=.*$/=\-1/' -i.bak /etc/php/7.4/apache2/php.ini && \
    sudo apt install composer -y && \
    composer require phpunit/php-code-coverage && \
    composer require vlucas/phpdotenv && \
    wget https://phar.phpunit.de/phpcov.phar && \
    mkdir log && \
    sudo chmod -R a+rwx log/ && \
    chmod +x run.sh && \
    pip3 install wheel && \
    pip3 install apache_log_parser
