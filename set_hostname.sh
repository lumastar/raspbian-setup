#!/bin/bash

USAGE="usage: set-hostname.sh {hostname}"

if [ "$#" -ne 1 ]; then
    echo "$USAGE"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "this script requires root privileges" 
   exit 1
fi

OLDHOSTNAME=`hostname`
NEWHOSTNAME=$1

# Change the host name in config files
sed -i -e "s/$OLDHOSTNAME/$NEWHOSTNAME/g" /etc/hosts
sed -i -e "s/$OLDHOSTNAME/$NEWHOSTNAME/g" /etc/hostname

exit 0