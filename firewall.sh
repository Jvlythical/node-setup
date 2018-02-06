#!/usr/bin/env bash

# This script will set up firewall rules on our slave servers.
# For now, I am not going to create a whitelist of ip addresses and ports.
# Instead, I am going to create just a blacklist.
# TODO: Consider using ufw since it already implements a good set of default
# rules.

# Dependencies:
# sudo apt-get install iptables-persistent netfilter-persistent
# sudo netfilter-persistent save
# sudo netfilter-persistent reload
#
# Resources:
# * https://crm.vpscheap.net/knowledgebase.php?action=displayarticle&id=29
# * https://www.rosehosting.com/blog/blocking-abusive-ip-addresses-using-iptables-firewall-in-debianubuntu/
# * https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands

# Allow ALL incoming SSH
iptables -A INPUT -p tcp --dport 2249 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2249 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow Outgoing SSH
iptables -A OUTPUT -p tcp --dport 2249 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 2249 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incoming HTTP and HTTPS
#iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
#iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -o eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# Allow Outgoing HTTPS
#iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# Block IPs
iptables -A INPUT -s 136.243.88.145 -j DROP
iptables -A OUTPUT -s 136.243.88.145 -j DROP
iptables -A INPUT -s 176.9.0.89 -j DROP
iptables -A OUTPUT -s 176.9.0.89 -j DROP
iptables -A INPUT -s 94.130.9.194 -j DROP
iptables -A OUTPUT -s 94.130.9.194 -j DROP
iptables -A INPUT -s 176.9.2.145 -j DROP
iptables -A OUTPUT -s 176.9.2.145 -j DROP
iptables -A INPUT -s 107.178.104.10 -j DROP
iptables -A OUTPUT -s 107.178.104.10 -j DROP
