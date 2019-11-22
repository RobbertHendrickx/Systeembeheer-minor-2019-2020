#!/bin/bash

while getopts t: option
do
case "${option}"
in
t) RECORD=${OPTARG};;
esac
done


if [ "$RECORD" = "CNAME" ]
then
	echo "$4	IN	CNAME	$5." >> "/etc/bind/zones/$5"
	DB="/etc/bind/zones/$4"
fi

if [ "$RECORD" = "A" ]
then
        echo "$4        IN      A   $5" >> "/etc/bind/zones/$6"
	DB="/etc/bind/zones/$5"
fi

if [ "$RECORD" = "MX" ]
then
        echo "$4        IN      MX   $5" >> "/etc/bind/zones/$6"
	DB="/etc/bind/zones/$5"
fi

serialline=$(grep "Serial" "$DB")
serialnumber=$(echo $serialline | cut -d \; -f 1)
((serialnumber++))
newserial="$serialnumber         ; Serial"
echo $newserial;
sed -i "s/.*Serial.*/\t\t\t     $newserial/g" "$DB"
echo "$1 $2 $3 $4 $5 $6 $7 $8 $9"

rndc reload
systemctl restart bind9

