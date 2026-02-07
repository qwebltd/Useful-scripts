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

echo "Fetching new Tor exit nodes list."

# Get a copy of the IP list
wget -qc $URL -O $FILE

# Iterate through the IPs
for IP in $( cat $FILE ); do

    # Is this an IPv4 or IPv6?
    if [[ $IP == *":"* ]]; then

        echo "Adding IPv6: $IP";

        # Add the ip address to the IPv6 chain
        $IP6TABLES -I $CHAIN 1 -p 0 -s $IP -j DROP

    else

        echo "Adding IPv4: $IP";

        # Add the ip address to the IPv4 chain
        $IPTABLES -I $CHAIN 1 -p 0 -s $IP -j DROP

    fi;

done

echo "Done!"

# Remove the list
unlink $FILE
