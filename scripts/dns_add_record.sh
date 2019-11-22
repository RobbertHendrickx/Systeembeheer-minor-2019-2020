#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root or sudo";
  exit 1;
fi

if [ -n "$1" ]; then
if [[ $1 = "-t" ]]; then
        case $2 in
        A )
        echo -e "$3             IN      A       $4" >> /etc/bind/zones/"$5"
        DB="/etc/bind/zones/$5"
        ;;
        MX )
        echo -e "@              IN      MX      10      $3.$5." >> /etc/bind/zones/"$5"
        echo -e "$3             IN      A       $4" >> /etc/bind/zones/"$5"
        DB="/etc/bind/zones/$5"
        ;;
        CNAME )
        DB="/etc/bind/zones/$4"
        echo -e "$3             IN      CNAME   $4." >> "$DB"
        ;;
        esac
        else
        echo -e "$1     IN      A       $2" >> /etc/bind/zones/"$3"
        DB="/etc/bind/zones/$3"
        fi

        serialline=$(grep "Serial" "$DB")
        serialnumber=$(echo $serialline | cut -d \; -f 1)
        ((serialnumber++))
        newserial="$serialnumber         ; Serial"
        echo $newserial;
        sed -i "s/.*Serial.*/\t\t\t     $newserial/g" "$DB"

        rndc reload
        systemctl restart bind9

else
        echo -e "This is not a valid use, try something like dns_add_record -t A test 12.34.56.78 foobar.slimme-rik.sb.uclllabs.be"
fi
