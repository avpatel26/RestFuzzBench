sudo apt  install default-jre

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
       /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

sudo systemctl start jenkins
sudo systemctl status jenkins

sudo ufw allow 8080
sudo ufw enable
sudo ufw status

sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar
