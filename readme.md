# Installation information:

- Selected O.S Debian 12 bookwhoorm.
- Disk partitioning (optional).

sda                 8:0    0   20G  0 disk 
└─sda1              8:1    0   20G  0 part 
  ├─Main-MainBoot 254:0    0  236M  0 lvm  /boot
  ├─Main-MainRoot 254:1    0  4.7G  0 lvm  /
  ├─Main-MainVar  254:2    0  6.5G  0 lvm  /var
  ├─Main-MainSwap 254:3    0  2.1G  0 lvm  [SWAP]
  └─Main-MainData 254:4    0  6.5G  0 lvm  /mnt/data

- Partitioned the disk with LVM, to ease the management of disks in the node, this will allow us to resize or extend partitions to new disks, or migrate an entore partition to another disk if it is necesary.
- Another good practice will be to add another disk exclusive to store mysql data and logs.

# O.S Information:

PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian

# Linux kernel information

Linux NODE-01 6.1.0-17-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.69-1 (2023-12-30) x86_64 GNU/Linux

# Installation process:

 - Setup the computer and the mysql-server with the commands in vm_setup.sh.
 - Setup necessary users and tables with mysql_setup.sql.
 - Improve high availability of the nodes with instructions in ha_setup.sh.

# HA solution selected:
Configure nodes with keepalived and create an script that connects to node 01 instance, if the script fails, the virtual IP address will balance to the node 02.
Setup a replication master - slave between node 01 and 02, node 01 being the master, in case of failure the Virtual IP will change to node 02 and this having the replication channel should be up to date and prevent database service downtime.
This configuration can be improved including ha proxy in a more advanced scenario.