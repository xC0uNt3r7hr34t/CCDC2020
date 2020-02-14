#!/bin/bash

# grab input from user for DNS server IPs
read -p 'IP of DNS Servers (place 1 space between IPs): ' DNS_SERVER

echo $DNS_SERVER

# CentOS Splunk

# run each command on your system to configure firewall

iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

for ip in $DNS_SERVER
do
	iptables -A OUTPUT -p udp -d $ip --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	iptables -A INPUT -p udp -s $ip --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
	iptables -A OUTPUT -p tcp -d $ip --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	iptables -A INPUT -p tcp -s $ip --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
done

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dport 80,443,8000 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sport 80,443,8000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 8089 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8089 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp --sport 123 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sport 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dport 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -j LOG -m limit 12/min --log-level 4 --log-prefix 'IP INPUT DROP: '
iptables -A INPUT -j DROP

iptables -A OUTPUT -j LOG -m limit 12/min --log-level 4 --log-prefix 'IP OUTPUT DROP: '
iptables -A OUTPUT -j DROP

yum install -y iptables-persistent

echo Firewalls added.

iptables -L

exit 0