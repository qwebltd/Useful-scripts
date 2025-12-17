#!/bin/bash
#
# Set this script up as a Cron job to run every morning, and it'll keep the IPTables firewall
# updated with current Tor exit nodes.
#
# This is essentially just a rehash of our Spamhaus firewall script, but uses an IP list by
# Daniel Austin, https://www.dan.me.uk

# path to iptables
IPTABLES="/sbin/iptables";

# list of known Tor exit nodes
URL="https://www.dan.me.uk/torlist/?exit";

# save local copy here
FILE="/tmp/tor.txt";

# iptables custom chain
CHAIN="Tor";

# check to see if the chain already exists
$IPTABLES -L $CHAIN -n

# check to see if the chain already exists
if [ $? -eq 0 ]; then

    # flush the old rules
    $IPTABLES -F $CHAIN

    echo "Flushed old rules. Applying updated Tor exit nodes list...."

else

    # create a new chain set
    $IPTABLES -N $CHAIN

    # tie chain to input rules so it runs
    $IPTABLES -A INPUT -j $CHAIN

    # don't allow this traffic through
    $IPTABLES -A FORWARD -j $CHAIN

    echo "Chain not detected. Creating new chain and adding Tor exit nodes list...."

fi;

# get a copy of the IP list
wget -qc $URL -O $FILE

# iterate through the IPs
for IP in $( cat $FILE ); do

    # add the ip address log rule to the chain
    $IPTABLES -A $CHAIN -p 0 -s $IP -j LOG --log-prefix "[TOR BLOCK]" -m limit --limit 3/min --limit-burst 10

    # add the ip address to the chain
    $IPTABLES -A $CHAIN -p 0 -s $IP -j DROP

    echo $IP

done

echo "Done!"

# remove the list
unlink $FILE
