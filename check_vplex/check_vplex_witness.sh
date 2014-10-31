#!/bin/bash

# VPLEX Witness check
# v1 2014-09-08 | MIK | ensimmäinen toimiva versio

#set -x
HOST=$1
USR=$2
PWD=$3
IFS='
'

status=( $( curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/cluster-witness/components/*/" |grep diagnostic -A1 |grep -v "name" | awk '{$1=""; print $0}' |grep -v "^$" | tr -d '"' >/tmp/vplex/witnessdata-$HOST) )

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

timestamp=( $( echo "Witness in-contact data collected at `date`" >> /tmp/vplex/witnessdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "in-contact" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/witnessdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "Witness state OK"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/witnessdata-$HOST
  exit 0
fi

