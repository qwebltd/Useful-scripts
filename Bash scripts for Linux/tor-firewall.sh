#!/bin/bash
#
# Set this script up as a Cron job to run every morning, and it'll keep the IPTables firewall
# updated with current Tor exit nodes.
#
# This is essentially just a rehash of our Spamhaus firewall script, but uses an IP list by
# Daniel Austin, https://www.dan.me.uk

# Path to IPTables
IPTABLES="/sbin/iptables";
IP6TABLES="/sbin/ip6tables";

# List of known Tor exit nodes
URL="https://www.dan.me.uk/torlist/?exit";

# Save local copy here
FILE="/tmp/tor.txt";

# IPTables custom chain
CHAIN="Tor";

# Check to see if the chain already exists

$IPTABLES -L $CHAIN -n

if [ $? -eq 0 ]; then

    # Flush the old rules
    $IPTABLES -F $CHAIN

    echo "Flushed old IPv4 rules."

else

    # Create a new chain set
    $IPTABLES -N $CHAIN

    # Tie chain to input rules so it runs
    $IPTABLES -A INPUT -j $CHAIN

    # Don't allow this traffic through
    $IPTABLES -A FORWARD -j $CHAIN

    echo "Creating new chain for IPv4 rules."

fi;

$IP6TABLES -L $CHAIN -n

if [ $? -eq 0 ]; then

    # Flush the old rules
    $IP6TABLES -F $CHAIN

    echo "Flushed old IPv6 rules."

else

    # Create a new chain set
    $IP6TABLES -N $CHAIN

    # Tie chain to input rules so it runs
    $IP6TABLES -A INPUT -j $CHAIN

    # Don't allow this traffic through
    $IP6TABLES -A FORWARD -j $CHAIN

    echo "Creating new chain for IPv6 rules."

fi;

echo "Fetching new Tor exit nodes list."

# Get a copy of the IP list
wget -qc $URL -O $FILE

# Iterate through the IPs
for IP in $( cat $FILE ); do

    # Is this an IPv4 or IPv6?
    if [[ $IP == *":"* ]]; then

        echo "Adding IPv6: $IP";

        # Add the ip address to the IPv6 chain
        $IP6TABLES -A $CHAIN -p 0 -s $IP -j DROP

    else

        echo "Adding IPv4: $IP";

        # Add the ip address to the IPv4 chain
        $IPTABLES -A $CHAIN -p 0 -s $IP -j DROP

    fi;

done

echo "Done!"

# Remove the list
unlink $FILE
