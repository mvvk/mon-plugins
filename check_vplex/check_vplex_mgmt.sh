#!/bin/bash

# VPLEX Witness check
# v1 2014-09-08 | MIK | ensimmäinen toimiva versio

#set -x
HOST=$1
USR=$2
PWD=$3
IFS='
'

status=( $( 
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/*/mgmt-modules/*?operational-status" |grep 'parent' | awk '{ print $2 }'  | tr -d ',' |tr -d '"' >/tmp/vplex/mgmt-parent-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/*/mgmt-modules/*?operational-status" |grep -A1 'operational-status' |grep -v "name" |grep -v "^-" | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/mgmt-status-$HOST
  paste -d " " /tmp/vplex/mgmt-parent-$HOST /tmp/vplex/mgmt-status-$HOST > /tmp/vplex/mgmtdata-$HOST
  rm /tmp/vplex/mgmt-parent-$HOST /tmp/vplex/mgmt-status-$HOST
) )

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

timestamp=( $( echo "Timestamp `date` (online)" >> /tmp/vplex/mgmtdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "online" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/mgmtdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "Management modules OK"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/mgmtdata-$HOST
  exit 0
fi

