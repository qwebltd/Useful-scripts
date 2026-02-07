#!/bin/bash
#
# Set this script up as a Cron job to run every morning, and it'll keep the IPTables firewall
# updated with current Spamhaus block lists.
#
# Originally based off of the following two scripts
# http://www.theunsupported.com/2012/07/block-malicious-ip-addresses/
# http://www.cyberciti.biz/tips/block-spamming-scanning-with-iptables.html

# Path to IPTables
IPTABLES="/sbin/iptables";
IP6TABLES="/sbin/ip6tables";

# List of known spammers
URL4="https://www.spamhaus.org/drop/drop_v4.json";
URL6="https://www.spamhaus.org/drop/drop_v6.json";

# Save local copy here
FILE4="/tmp/drop4.txt";
FILE6="/tmp/drop6.txt";

# IPTables custom chain
CHAIN="Spamhaus";

# Check to see if the chain already exists

$IPTABLES -L $CHAIN -n

if [ $? -eq 0 ]; then

    # Flush the old rules
    $IPTABLES -F $CHAIN

    # Also remove the INPUT tie if it exists, so that we can recreate it at the top
    $IPTABLES -D INPUT -j $CHAIN

    echo "Flushed old IPv4 rules."

else

    # Create a new chain set
    $IPTABLES -N $CHAIN

    echo "Creating new chain for IPv4 rules."

fi;

$IP6TABLES -L $CHAIN -n

if [ $? -eq 0 ]; then

    # Flush the old rules
    $IP6TABLES -F $CHAIN

    # Also remove the INPUT tie if it exists, so that we can recreate it at the top
    $IP6TABLES -D INPUT -j $CHAIN

    echo "Flushed old IPv6 rules."

else

    # Create a new chain set
    $IP6TABLES -N $CHAIN

    echo "Creating new chain for IPv6 rules."

fi;

# We're going to tie these chains to INPUT, so make sure the last rule returns back there
$IPTABLES -A $CHAIN -j RETURN
$IP6TABLES -A $CHAIN -j RETURN

# Tie chains to input
$IPTABLES -I INPUT 1 -j $CHAIN
$IP6TABLES -I INPUT 1 -j $CHAIN

echo "Fetching new IPv4 list.";

# Get a copy of the IP lists
wget -qc $URL4 -O $FILE4
wget -qc $URL6 -O $FILE6

# Iterate through the IPs

for IP in $( cat $FILE4 | jq -r '.cidr' ); do

    if [ $IP != "null" ]; then

        echo "Adding IPv4: $IP";

        # Add the IP address to the chain
        $IPTABLES -I $CHAIN 1 -p 0 -s $IP -j DROP

    fi;

done

for IP in $( cat $FILE6 | jq -r '.cidr' ); do

    if [ $IP != "null" ]; then

        echo "Adding IPv6: $IP";

        # Add the IP address to the chain
        $IP6TABLES -I $CHAIN 1 -p 0 -s $IP -j DROP

    fi;

done

echo "Done!"

# Remove the lists
unlink $FILE4
unlink $FILE6
