#!/bin/bash
#
# Set this script up as a Cron job to run weekly, and it'll keep the IPTables firewall
# updated with current IP ranges belonging to untrustworthy networks.
#
# This primarily pulls in the ASN Drop list by Spamhaus, but you can add ASNs for any network
# to the custom ASN list below to include blocking those out too.
#
# To convert ASNs into blockable IP lists, this script uses QWeb Ltd's ASN Lookup API which
# you'll need an access key for.
#   https://apis.qweb.co.uk/asn-lookup/
#
# You can also use QWeb Ltd's free IP tool to find the ASN of any IP address. If your server
# is receiving malicious traffic or an excessive number of requests from IPs belonging to the
# same ASN, you might want to consider adding that ASN here.
#   https://ip-tool.qweb.co.uk/
#
# You might also want to use our Spamhaus firewall and Tor firewall scripts:
#   https://github.com/qwebltd/Useful-scripts/blob/main/Bash%20scripts%20for%20Linux/spamhaus-firewall.sh
#   https://github.com/qwebltd/Useful-scripts/blob/main/Bash%20scripts%20for%20Linux/tor-firewall.sh

# ASN Lookup API access key. Get this from here: https://apis.qweb.co.uk/asn-lookup/
ASNLOOKUPKEY="";

# Custom ASNs to block in addition to the Spamhaus list. Separate with spaces:
ASNLIST=();
# For example, to block ALIBABA-CN-NET ASNs:
# ASNLIST=("37963" "45102");

# Path to IPTables
IPTABLES="/sbin/iptables";
IP6TABLES="/sbin/ip6tables";

# List of untrustworthy ASNs
URL="https://www.spamhaus.org/drop/asndrop.json";

# Save local copy here
FILE="/tmp/asns.txt";

# We also need a temp file to save IP lists to during the ASN iteration
FILEIPS="/tmp/asnips.txt";

# IPTables custom chain
CHAIN="Untrusted-ASN";

# First, we only want to continue if there's a valid lookup key:
if [[ -z $ASNLOOKUPKEY ]]; then
	echo "Please populate ASNLOOKUPKEY with your API access key before running this script.";
	exit 1;
fi;

# Check to see if the chain already exists

$IPTABLES -L $CHAIN -n

if [ $? -eq 0 ]; then

    # Flush the old rules
    $IPTABLES -F $CHAIN

    # Also remove the INPUT tie if it exists, so that we can recreate it at the top
    $IPTABLES -D INPUT -j $CHAIN

    echo "Flushed old IPv4 rules.";

else

    # Create a new chain set
    $IPTABLES -N $CHAIN

    echo "Creating new chain for IPv4 rules.";

fi;

$IP6TABLES -L $CHAIN -n

if [ $? -eq 0 ]; then

    # Flush the old rules
    $IP6TABLES -F $CHAIN

    # Also remove the INPUT tie if it exists, so that we can recreate it at the top
    $IP6TABLES -D INPUT -j $CHAIN

    echo "Flushed old IPv6 rules.";

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

echo "Fetching new ASNs list.";

# Get a copy of the ASNs list
wget -qc $URL -O $FILE

# Iterate the downloaded ASNs and also the custom additions defined above
for ASN in $( cat $FILE | jq -r '.asn' && printf '%s\n' "${ASNLIST[@]}" ); do

	if [ $ASN != "null" ]; then

		# Convert the ASN into an IP list
		wget -qN "https://apis.qweb.co.uk/asn-lookup/$ASNLOOKUPKEY/$ASN.json" -O $FILEIPS

		if [[ "$(cat $FILEIPS | jq -r '.answer')" == "success" ]]; then

			# Iterate through the IPs
			for IP in $( cat $FILEIPS | jq -r '.ipv4[]' ); do

				if [ $IP != "null" ]; then

					echo "Adding IPv4: $IP";

					# Add the ip address to the IPv6 chain
					$IPTABLES -I $CHAIN 1 -p 0 -s $IP -j DROP

				fi;

			done

			for IP in $( cat $FILEIPS | jq -r '.ipv6[]' ); do

				if [ $IP != "null" ]; then

					echo "Adding IPv6: $IP";

					# Add the ip address to the IPv4 chain
					$IP6TABLES -I $CHAIN 1 -p 0 -s $IP -j DROP

				fi;

			done

		else

			echo "$(cat $FILEIPS | jq -r '.answer')";

		fi;

	fi;

done

echo "Done!";

# Remove the files
unlink $FILE
unlink $FILEIPS
