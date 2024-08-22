#!/bin/bash

echo "***********************************************************************************************************"
echo
echo "hostname:"
hostname
echo
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo
echo "hostname -f:"
hostname -f
echo
echo "***********************************************************************************************************"
echo
echo "hostnamectl:"
hostnamectl
echo
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo
echo "timedatectl :"
timedatectl
echo
echo "***********************************************************************************************************"
echo
echo "cat /etc/timezone:"
cat /etc/timezone
echo
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo
echo "systemctl status unattended-upgrades :"
systemctl status unattended-upgrades
echo
echo "***********************************************************************************************************"
echo
echo "echo \$USER:"
echo $USER
echo
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo
echo "groups :"
groups
echo
echo "***********************************************************************************************************"
echo
echo "groups \$USER:"
echo groups $USER
echo
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo
echo ".ssh permissions shoudld be drwx------"
ls -la /home/$USER | grep -w ".ssh"
echo
echo "***********************************************************************************************************"
echo
echo "authorized_keys permissions should be -rw-------"
ls -la /home/$USER/.ssh | grep -w "authorized_keys"
echo
echo "***********************************************************************************************************"
echo
echo "sudo ufw status verbose:"
sudo ufw status verbose
echo
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo
echo "service fail2ban status"
service fail2ban status
echo
echo "***********************************************************************************************************"
echo "sudo apt update"
echo "sudo apt upgrade"
echo "sudo apt dist-upgrade"
echo "sudo apt autoremove"