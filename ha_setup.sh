#In this document we will setup Keepalived in both of the nodes to ensure a simple failover node balancing.
# Important! Both node should be equally configured.
# Node 01 Instructions.
#Install keepalived.
sudo apt install keepalived

#Configure node 01 keepalived as MASTER.
sudo echo "
global_defs {
    enable_script_security
    script_user giglnxdmn
}

vrrp_script check_node01 {
    script "/etc/keepalived/chk_node01.sh"
    interval 5
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 51
    priority 102
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        192.168.56.5/24
    }
    track_script {
      check_node01
    }
}
" | sudo tee -a /etc/keepalived/keepalived.conf

#Configure a custom check script, this script will check if the mysql instance is accepting connections through port 5566.
#To do so we will need to add some extra components.
#Create new check user in our instance that can login from the node 02 address and only with connect permission.
CREATE USER 'ha_check'@'localhost' IDENTIFIED BY 'Temporal';
GRANT USAGE ON *.* TO 'ha_check'@'localhost';
FLUSH PRIVILEGES;

#Configure check script.
#Create script /etc/keepalived/node01_check.sh and paste following code.
#This script will check that node 2 is able to connect to node 1, if not, keepalived of node 2 should change role to master.
sudo nano /etc/keepalived/chk_node01.sh
################ CODE ####################
#!/bin/bash
timeout 5 mysql --user=ha_check --port=5566 --password=Temporal --execute="SELECT 1;" 2>/dev/null

if [ $? -eq 0 ]; then
    exit 0
fi

exit 1
#########################################

# Node 02 instructions.
#Deploy node number 2 as a mirror of node number one, should be easy following vm_setup.sh procedure.
#Install keepalived.
sudo apt install keepalived

#Configure node 02 keepalived as BACKUP.
sudo echo "
vrrp_instance VI_2 {
    state BACKUP
    interface enp0s8
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        192.168.56.5/24
    }
}
" | sudo tee -a /etc/keepalived/keepalived.conf

#Restart keepalived in both nodes.
sudo systemctl restart keepalived

#With this configuration when we stop mysql of node 01 the virtual IP should load balance to the node 02.
#Next step is to configure a MySQL replication Master - Slave.
# Back to NODE 01 (Master).
#Assign server id.
echo "server-id = 1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set logbin file location.
echo "log_bin = /var/log/mysql/mysql-bin.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Database to be included in the binary logging.
echo "binlog-do-db = MusicStore" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set SSL Certificates.
echo "ssl-ca = /mnt/data/node01/data/ca.pem" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "ssl-cert = /mnt/data/node01/data/server-cert.pem" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "ssl-key = /mnt/data/node01/data/server-key.pem" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

#Create a user for the replication.
CREATE USER 'replication_user'@'192.168.56.11' IDENTIFIED BY 'Temporal';
GRANT REPLICATION SLAVE, RELOAD, REPLICATION CLIENT ON *.* TO 'replication_user'@'192.168.56.11';
FLUSH PRIVILEGES;
#Restart mysql server.
sudo systemctl restart mysql | sudo tail -f /var/log/mysql/error.log

# Configure Node 02.
#Configure node 2 server id.
echo "server-id = 2" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Set relay log file location.
echo "relay-log = /var/log/mysql/mysql-relay-bin.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#Database to be included in the binary logging.
echo "binlog-do-db = MusicStore" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

#Create a user for the replication.
CREATE USER 'replication_user'@'192.168.56.10' IDENTIFIED BY 'Temporal';
GRANT REPLICATION SLAVE, RELOAD, SUPER ON *.* TO 'replication_user'@'192.168.56.10';
FLUSH PRIVILEGES;

#Restart mysql server.
sudo systemctl restart mysql | sudo tail -f /var/log/mysql/error.log

#Setup replication no node 02 (Slave.)
CHANGE MASTER TO
  MASTER_HOST='192.168.56.10',
  MASTER_PORT=5566,
  MASTER_USER='replication_user',
  MASTER_PASSWORD='Temporal',
  MASTER_LOG_FILE='mysql-bin.000002',
  MASTER_LOG_POS=157,
  GET_MASTER_PUBLIC_KEY=1;

START SLAVE;

#This should bring up the slave replication.
#Then we have a virtual IP address that will fail if node 01 is out or if mysql server of node 01 is stopped.