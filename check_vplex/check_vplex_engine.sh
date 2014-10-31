#!/bin/bash

# VPLEX Engine check
# v1 2014-09-08 | MIK | ensimmäinen toimiva versio

#set -x
HOST=$1
USR=$2
PWD=$3
IFS='
'

status=( $( 
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/" |grep -A1 'engine-id' |grep -v "name" |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/engid-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/" |grep -A1 'operational-status' |grep -v "name" |grep -v "^-" | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/engops-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/" |grep -A1 'health-state' |grep -v "name" |grep -v "^-" | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/enghealth-$HOST
  paste -d " " /tmp/vplex/engid-$HOST /tmp/vplex/engops-$HOST /tmp/vplex/enghealth-$HOST > /tmp/vplex/engdata-$HOST  
  rm /tmp/vplex/engid-$HOST /tmp/vplex/engops-$HOST /tmp/vplex/enghealth-$HOST
) ) 

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

timestamp=( $( echo "Timestamp `date` (online ok)" >> /tmp/vplex/engdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "online ok" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/engdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "Engine operational status & health OK"
  echo "id, status, health"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/engdata-$HOST
  exit 0
fi

