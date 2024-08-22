#!/bin/bash


echo
echo "hostname:"
hostname

echo
echo "hostname -f:"
hostname -f

echo
echo "hostnamectl:"
hostnamectl

echo
echo "timedatectl :"
timedatectl

echo
echo "cat /etc/timezone:"
cat /etc/timezone

echo
echo "systemctl status unattended-upgrades :"
systemctl status unattended-upgrades

echo
echo "echo \$USER:"
echo $USER

echo
echo "groups :"
groups

echo
echo "groups \$USER:"
echo groups $USER

echo
echo ".ssh permissions shoudld be drwx------"
ls -la /home/$USER | grep -w ".ssh"

echo
echo "authorized_keys permissions should be -rw-------"
ls -la /home/$USER/.ssh | grep -w "authorized_keys"


echo
echo "sudo ufw status verbose:"
sudo ufw status verbose

echo
echo "service fail2ban status"
service fial2ban status


