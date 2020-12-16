#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing MariaDB 10.5"

#create repo
cat <<EOF | tee -a /etc/yum.repos.d/mariadb105.repo
# MariaDB 10.5 CentOS repository list
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

#generate a random root password
root_password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#included in the distribution
yum -y update
yum -y install MariaDB-server MariaDB-client

#send a message
verbose "Initalize MariaDB database"

#systemd
systemctl daemon-reload
systemctl enable mariadb
systemctl restart mariadb

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

#add the databases, users and grant permissions to them
sudo mysql -u root -p$root_password -e "DROP DATABASE test";
sudo mysql -u root -p$root_password -e "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost'";
sudo mysql -u root -p$root_password -e "DELETE FROM mysql.user WHERE User=''";
sudo mysql -u root -p$root_password -e "FLUSH PRIVILEGES";

sudo mysql -u root -p$root_password -e "CREATE DATABASE fusionpbx";
sudo mysql -u root -p$root_password -e "CREATE DATABASE freeswitch";

sudo mysql -u root -p$root_password -e "CREATE USER 'fusionpbx'@'localhost' IDENTIFIED BY '"$password"';";
sudo mysql -u root -p$root_password -e "GRANT ALL PRIVILEGES ON fusionpbx.* TO 'fusionpbx'@'localhost';";
sudo mysql -u root -p$root_password -e "FLUSH PRIVILEGES;";

sudo mysql -u root -p$root_password -e "CREATE USER 'freeswitch'@'localhost' IDENTIFIED BY '"$password"';";
sudo mysql -u root -p$root_password -e "GRANT ALL PRIVILEGES ON freeswitch.* TO 'fusionpbx'@'localhost';";
sudo mysql -u root -p$root_password -e "GRANT ALL PRIVILEGES ON freeswitch.* TO 'freeswitch'@'localhost';";
sudo mysql -u root -p$root_password -e "FLUSH PRIVILEGES;";

#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd

#send a message
verbose "MariaDB 10.5 installed"
