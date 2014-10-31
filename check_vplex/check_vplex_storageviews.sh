#!/bin/bash

# VPLEX Storage-view check
# v1 2014-09-08 | MIK | ensimmäinen toimiva versio

#set -x
HOST=$1
USR=$2
PWD=$3
IFS='
'

status=( $( 
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/clusters/*/exports/storage-views/*?operational-status" |grep value | awk '{ print $2 }' |tr -d '"' >/tmp/vplex/storview_stat_tmp-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/clusters/*/exports/storage-views/*?name" |grep value | awk '{ print $2 }' |tr -d '"' >/tmp/vplex/storview_name_tmp-$HOST
  paste -d " " /tmp/vplex/storview_name_tmp-$HOST /tmp/vplex/storview_stat_tmp-$HOST > /tmp/vplex/storageviewdata-$HOST  
  rm /tmp/vplex/storview_name_tmp-$HOST /tmp/vplex/storview_stat_tmp-$HOST
) ) 

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

timestamp=( $( echo "Storage-view data collected ok at `date`" >> /tmp/vplex/storageviewdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "ok" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/storageviewdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "Storage-view operational status OK"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/storageviewdata-$HOST
  exit 0
fi

