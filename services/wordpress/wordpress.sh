#!/bin/bash  
   
###### wordpress installation #####  
  
## system update  
 apt-get update -y  
   
 ## Install Apache web server  
 sudo apt-get install apache2 apache2-utils -y  
 systemctl start apache2  
 systemctl enable apache2  
   
 ## Install PHP  
 apt-get install php libapache2-mod-php php-mysql -y  
   
 ## Install MySQL database server  
read -p 'Enter db_root_password: ' db_password  
export DEBIAN_FRONTEND="noninteractive"  
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_password"  
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_password"  
 apt-get install mysql-server mysql-client -y  
   
 ## Install Latest WordPress 
 
 rm /var/www/html/index.*  
 wget -c http://wordpress.org/latest.tar.gz  
 tar -xzvf latest.tar.gz  
 rsync -av wordpress/* /var/www/html/  
   
 chown -R www-data:www-data /var/www/html/  
 chmod -R 755 /var/www/html/  
   
 ## Configure WordPress Database
read -p 'Enter wordpress_db_name: ' db_name   
mysql -uroot -p$db_password <<QUERY_INPUT  
CREATE DATABASE $db_name;  
GRANT ALL PRIVILEGES ON $db_name.* TO 'root'@'localhost' IDENTIFIED BY '$db_password';  
FLUSH PRIVILEGES;  
EXIT
QUERY_INPUT
   
 ## Add Database Credentias in wordpress  
 cd /var/www/html/  
 sudo mv wp-config-sample.php wp-config.php  
 perl -pi -e "s/database_name_here/$db_name/g" wp-config.php  
 perl -pi -e "s/username_here/root/g" wp-config.php  
 perl -pi -e "s/password_here/$db_password/g" wp-config.php  
   
 a2enmod rewrite  
 php5enmod mcrypt  
   
 ## Install PhpMyAdmin  
 apt-get install phpmyadmin -y     
echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf  
   
 ## Restart Apache and Mysql  
 service apache2 restart  
 service mysql restart  
     
 echo "Installation is complete."  
