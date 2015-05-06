#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PHP_CONFIG_FILE="/etc/php5/apache2/php.ini"
XDEBUG_CONFIG_FILE="/etc/php5/mods-available/xdebug.ini"
MYSQL_CONFIG_FILE="/etc/mysql/my.cnf"

/usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Update the server
apt-get update
apt-get -y upgrade

if [[ -e /var/lock/vagrant-provision ]]; then
    exit;
fi

##################################################
#                                                #
# All the following commands need to be run only #
# one time.                                      #
#                                                #
##################################################

echo "Set up environment..."
`cat >/home/vagrant/.environment <<\EOF
# Environment variables

# A nice colorized prompt
export PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;33m\]\h\[\033[0m\]\[\033[1;37m\] \w \r\n\[\033[0m\]$ "

alias l="ls -lA"
alias ll="ls -lAhG"

# Load secret keys, if any.
if [ -f ~/.secret_keys ]; then
    source ~/.secret_keys
fi

# Include local bin directory in PATH, if exists.
if [ -d $HOME/bin ]; then
    export PATH=$PATH:$HOME/bin
fi

# Include composer bin directory, if exists.
if [ -d $HOME/.composer/vendor/bin ]; then
    export PATH=$PATH:$HOME/.composer/vendor/bin
fi
EOF
`
echo "source ~/.environment" >> /home/vagrant/.bash_profile

# Load secret keys if exists


# Set swap memory
dd if=/dev/zero of=/swapfile bs=1024 count=256k
mkswap /swapfile
swapon /swapfile
echo "/swapfile    none    swap    sw    0    0" | tee -a /etc/fstab
echo "10" | tee /proc/sys/vm/swappiness
echo "vm.swappiness = 10" | tee -a /etc/sysctl.conf
chown root:root /swapfile
chmod 0600 /swapfile

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
sed -i "s/^${IPADDR}.*//" /etc/hosts
echo $IPADDR ubuntu.localhost >> /etc/hosts

# Install basic tools
apt-get -y install build-essentials binutils-doc git

# Install Apache and PHP
apt-get -y install apache2
apt-get -y install php5 php5-curl php5-mysql php5-sqlite php5-xdebug php5-mcrypt

sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${PHP_CONFIG_FILE}
sed -i "s/display_errors = Off/display_errors = On/g" ${PHP_CONFIG_FILE}

cat << EOF > ${XDEBUG_CONFIG_FILE}
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_host=10.0.2.2
EOF

# Install MySQL
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
apt-get -y install mysql-client mysql-server

sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${MYSQL_CONFIG_FILE}

# Allow root access from any host
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

# Restart services
service apache2 restart
service mysql restart

rm /var/www/html/index.html

touch /var/lock/vagrant-provision
