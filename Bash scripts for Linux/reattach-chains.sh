#!/bin/bash
#
# If using our spamhaus-firewall.sh, tor-firewall.sh, and/or asn-firewall.sh scripts, you'll want this one too.
#
# This script reattaches our custom firewall chains to IPTables' INPUT.
# Attach this script to the Firewall Rules Activated event in Plesk's Event Manager to run this after any Plesk firewall saves.
# Otherwise when you save changes to the firewall via Plesk, these custom chains get detached.

# Path to IPTables
IPTABLES="/sbin/iptables";
IP6TABLES="/sbin/ip6tables";

# Chains
CHAINLIST=("Spamhaus" "Tor" "Untrusted-ASN");

for CHAIN in $( printf '%s\n' "${CHAINLIST[@]}" ); do

    $IPTABLES -L $CHAIN -n

    if [ $? -eq 0 ]; then

        $IPTABLES -D INPUT -j $CHAIN
        $IPTABLES -I INPUT 1 -j $CHAIN

    fi;

    $IP6TABLES -L $CHAIN -n

    if [ $? -eq 0 ]; then

        $IP6TABLES -D INPUT -j $CHAIN
        $IP6TABLES -I INPUT 1 -j $CHAIN

    fi;

done
