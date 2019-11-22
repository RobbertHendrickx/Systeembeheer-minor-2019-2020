#!/bin/bash


if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit
fi

mkdir "/var/log/apache2/$1"

mkdir "/var/www/$1"

echo "<VirtualHost *:80>
             ServerName $1
             DocumentRoot "/var/www/$1"
             ErrorLog "/var/log/apache2/$1"/error.log
             CustomLog "/var/log/apache2/$1"/access.log combined
     </VirtualHost>" > "/etc/apache2/sites-available/$1.conf"

sub=$(echo $1|grep -oP ".+(?=(\.robbert-hendrickx))")
echo "welcome $sub" > "/var/www/$1/index.html"

a2ensite $1> /dev/null
systemctl reload apache2
