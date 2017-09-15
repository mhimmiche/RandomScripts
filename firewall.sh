#!/bin/bash
# NAME: Mehdi Himmiche
echo -n "Starting firewall: "
IPTABLES="/sbin/iptables" # path to iptables
$IPTABLES --flush


# the network interface you want to protect
# NOTE: This may not be eth0 on all nodes -- use ifconfig to
# find the experimental network (10.1.x.x) and adjust this
# variable accordingly. Use the variable by putting a $ in
# front of it like so: $ETH . It can go in any command line
# and will be expanded by the shell.

# For example: iptables -t filter -i $ETH etc... 

ETH="eth0"
ETHout="eth5"
clientIP="10.1.1.3"
serverIP="10.1.2.3"
fwIP="10.1.1.3"
# all traffic on the loopback device (127.0.0.1 -- localhost) is OK.
# Don't touch this!
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

# Your changes go below this line:
# ---8<---------------------------

# Allow all inbound and outbound traffic; all protocols, states,
# addresses, interfaces, and ports (it's like no firewall at all!):
#$IPTABLES -t filter -A INPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
#$IPTABLES -t filter -A OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

# You probably want to comment out the above "firewall".

# Put NEW firewall rules here:
# (Each "instruction" may represent multiple iptables rules)

# Allow SSH onto the Firewall
$IPTABLES -A INPUT -s 0/0 -i $ETH -p tcp --dport 22 -m state --state ESTABLISHED,NEW -j ACCEPT
# ALlow SSH onto the internal node
#$IPTABLES -A INPUT -s 0/0 -i $ETH -d $serverIP -p tcp --dport 22 -m state --state ESTABLISHED,NEW -j ACCEPT
# Allow traffic on port 80, 3306, and UDP traffic to the internal node
$IPTABLES -A INPUT -s 0/0 -i $ETH -d $serverIP -p tcp --dport 80 -j ACCEPT
$IPTABLES -A INPUT -s $clientIP -i $ETH -d $serverIP -p tcp --dport 3306 -j ACCEPT
$IPTABLES -A INPUT -s $clientIP -i $ETH -p udp --dport 10000:10005 -j ACCEPT
# ICMP Rules
$IPTABLES -A INPUT -s 0/0 -i $ETH -d $serverIP -p icmp -j ACCEPT
$IPTABLES -A OUTPUT -s $serverIP -o $ETH -d 0/0 -p icmp -j ACCEPT
# Outboud SSH communication from firewall
$IPTABLES -A OUTPUT -o $ETH -d 0/0 -p tcp --sport 22 -m state --state ESTABLISHED,NEW -j ACCEPT
# Outbound traffic from internal node
# $IPTABLES -A OUTPUT -s $serverIP -o $ETH -d 0/0 -p tcp --sport 22 -m state --state ESTABLISHED,NEW -j ACCEPT
$IPTABLES -A OUTPUT -s $serverIP -o $ETH -d 0/0 -p tcp --sport 25 -j ACCEPT
$IPTABLES -A OUTPUT -s $serverIP -o $ETH -d 0/0 -p tcp --sport 80 -j ACCEPT
$IPTABLES -A OUTPUT -o $ETH -d $clientIP -p udp --sport 10006:10010 -j ACCEPT

# Prem: Here are some rules to get you started. 
# Prevent SPOOFING of the SERVER
# --------------------
$IPTABLES -A INPUT -s $serverIP -j DROP




# helpful divisions:
# EXISTING CONNECTIONS
# --------------------
# Rules here specifically allow inbound traffic and outbound traffic for ALL previously
# accepted connections.

# Internal Network Traffic is still allowed!
$IPTABLES -A INPUT -i $ETH -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o $ETH -m state --state ESTABLISHED -j ACCEPT

# start writing your rules here... 
$IPTABLES -A INPUT -i $ETH -s 0/0 -j DROP 


# No changes below this line:
# ---8<---------------------------
echo "done."

