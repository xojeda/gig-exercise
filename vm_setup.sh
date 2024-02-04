#Commands to setup a Debian 12 Bookwhorm with new MYSQL server step by step.
#Make sure your virtual machine has internet access.

#Elevate to root loading environment.
su -

#Configure main debian 12 repositories.

echo "# Debian Main Repositories
deb http://deb.debian.org/debian/ bookworm main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free

# Debian Security Updates
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free

# Debian Updates
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free" > /etc/apt/sources.list

#Update and upgrade to lastest S.O version, always improtant.
apt update && apt upgrade

#Install and cofnigure sudo.
apt install sudo

#Once sudo is set up logout.
logout

#Install useful tools.
sudo apt install -y wget net-tools rsync

#Download repository .deb.
sudo wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb

#Fix APT Error Download is performed unsandboxed as root.
echo 'APT::Sandbox::User "root";' | sudo tee /etc/apt/apt.conf.d/10sandbox

#Add repository.
#Select mysql-server8.0.
sudo apt install ./mysql-apt-config_*_all.deb

#Delete apt sandbox config, this could be a security concern.
sudo rm /etc/apt/apt.conf.d/10sandbox

#Update mysql packages
sudo apt update

#Install mysql-server
sudo apt install mysql-server

#Stop mysql server to change the configuration.
sudo systemctl stop mysql

#Create folder that will contain our mysql node files.
sudo mkdir -p /mnt/data/node01
sudo mkdir -p /mnt/data/node01/data
#Change the apropiate permissions.
sudo chown -R mysql:mysql /mnt/data/node01/*
#Copy all data located in default instllation path /var/lib/mtsql/ to new destination path /mnt/data/node01/data/
sudo rsync -av /var/lib/mysql/ /mnt/data/node01/data/
#Customize mysql server node configuration file.
sudo sed -i 's|^datadir.*|datadir = /mnt/data/node01/data|' /etc/mysql/mysql.conf.d/mysqld.cnf
#Add base dir for the node.
echo "basedir = /mnt/data/node01" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Enable slow query log to check for long duration querys.
echo "slow_query_log = 1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "slow_query_log_file = /var/log/mysql/mysql-slow.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Add mysql server desired connection port.
echo "port=5566" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Add some standerd optimization options.
#Set Innodb buffer pool size, adjust depending on VM memory.
echo "innodb_buffer_pool_size = 1G" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set Innodb_log_size.
echo "innodb_log_file_size = 256M" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set thread cache size.
echo "thread_cache_size = 16" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set thread stack.
echo "thread_stack = 192K" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set max connections
echo "max_connections = 100" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set timeouts.
echo "wait_timeout = 300" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "interactive_timeout = 300" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set max packet for big querys.
echo "max_allowed_packet = 16M" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Enable performance schema.
echo "performance_schema = ON" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set temp tables size limit and 
echo "tmp_table_size = 64M" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "max_heap_table_size = 64M" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

#Start mysql server, and check error log to check that there is no major errors.
sudo systemctl start mysql | sudo tail -f /var/log/mysql/error.log

#Clean old data folder 
sudo rm -rf /var/lib/mysql/

#Add basic security to our mysql instance.
sudo mysql_secure_installation
#Careful, it depends on the selection of choices the installation process may differ:
#My answers:
# VALIDATE PASSWORD component N
# Change root password N
# Delete anonymous users Y
# Disallow root login remotely Y
# Remove test database and access to it Y
# Reload privilege tables now Y