#!/bin/bash

###### wordpress installation #####

echo "Wordpress installation started"

export db_name=$1
export db_password=$2

## system update
apt-get update -y

## Install MySQL database server
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_password"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_password"

service mysql start

## Install wp-cli for wordpress
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

## Install wordpress
mkdir wordpress
cd wordpress
wp core download --allow-root

##sudo apt install rsync grsync

rm /var/www/html/index.*
cd ..
rsync -av wordpress/* /var/www/html/

chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/


## Setup database for wordpress
mysql -u root -p$db_password << QUERY_INPUT
CREATE DATABASE $db_name;
GRANT ALL PRIVILEGES ON $db_name.* TO 'root'@'localhost' IDENTIFIED BY '$db_password';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_password';
FLUSH PRIVILEGES;
EXIT
QUERY_INPUT

## Configure wordpress site
cd /var/www/html/
wp config create --dbname=$db_name --dbuser=root --dbpass=$db_password --locale=ro_RO --allow-root

wp core install --url=localhost/restfuzz.com --title=restfuzz --admin_user=root --admin_password=root --admin_email=avi@gmail.com --allow-root

sudo mv /home/ubuntu/.htaccess /var/www/html/
sudo cp /home/ubuntu/webapi.json /var/www/html/
chmod 664 .htaccess

cd /var/www/html/wp-content/plugins/

git clone https://github.com/WP-API/Basic-Auth.git
wp plugin activate Basic-Auth --allow-root

a2enmod rewrite
php5enmod mcrypt

## Install PhpMyAdmin
apt-get install phpmyadmin -y
echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf


mysql -u root -p$db_password << QUERY_INPUT
use $db_name;
update wp_options SET option_value = '/archives/%post_id%' where option_name = 'permalink_structure';
EXIT
QUERY_INPUT

rm -rf latest.tar.gz wordpress

echo  " Wordpress Installation is Complete"
