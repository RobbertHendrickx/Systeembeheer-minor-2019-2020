#!/bin/bash

DOMAIN="$1"

if [ "$#" -ge 2 ] || [ "$#" -eq 0 ]
then
	echo "Syntax: $(basename $0) subzonename"
	echo "$(basename $0) subzonename"
	exit 1
fi

SERIAL=$(date +"%Y%m%d")01                     # Serial yyyymmddnn

{
###### start SOA ######
echo "\$TTL 604800 	"
echo "@	IN	SOA	ns.$DOMAIN.robbert-hendrickx.sb.uclllabs.be	root.$DOMAIN.robbert-hendrickx.sb.uclllabs.be("
echo "			${SERIAL}		; Serial yyyymmddnn"
echo "			604800			; Refresh After 3 hours"
echo "			86400			; Retry Retry after 1 hour"
echo "			2419200		; Expire after 1 week"
echo "			604800)		; Minimum negative caching of 1 hour"
echo ""

###### start Name servers #######

# use for loop read all nameservers
echo ""
echo "; Name servers for $DOMAIN"
echo "@		IN	NS	ns.$DOMAIN.robbert-hendrickx.sb.uclllabs.be"
echo "@		IN	NS	ns.robbert-hendrickx.sb.uclllabs.be"

 

###### start A pointers #######
# A Records - Default IP for domain 
echo ""
echo '; A Records'
echo "ns	IN 	A	193.191.177.170"
echo "@         IN      A       193.191.177.170"

} > "/etc/bind/zones/$DOMAIN.robbert-hendrickx.sb.uclllabs.be"

{
echo "zone \"$DOMAIN.robbert-hendrickx.sb.uclllabs.be\" {"
echo "	type master;"
echo "	file \"/etc/bind/zones/$DOMAIN.robbert-hendrickx.sb.uclllabs.be\";"
echo "};"
} >> /etc/bind/named.conf.local

{
echo "$DOMAIN   IN      A       193.191.177.170"
} >> /etc/bind/zones/robbert-hendrickx.sb.uclllabs.be

serialline=$(grep "Serial" /etc/bind/zones/robbert-hendrickx.sb.uclllabs.be)
serialnumber=$(echo $serialline | cut -d \; -f 1)
((serialnumber++))
newserial="$serialnumber	; Serial"
echo $newserial;
sed -i "s/.*Serial.*/\t\t\t	$newserial/g" /etc/bind/zones/robbert-hendrickx.sb.uclllabs.be

rndc reload
systemctl restart bind9
