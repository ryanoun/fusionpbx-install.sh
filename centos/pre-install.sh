#!/bin/sh

#install git
yum -y install git

#get the install script
cd /usr/src && git clone --branch centos7-php74-mariadb105 https://github.com/ryanoun/fusionpbx-install.sh.git

#change the working directory
cd /usr/src/fusionpbx-install.sh/centos
