#!/bin/bash

# VPLEX Internal disks check
# v1 2014-09-08 | MIK | ensimmäinen toimiva versio

#set -x
HOST=$1
USR=$2
PWD=$3
IFS='
'

status=( $( 
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/*/directors/*/hardware/internal-disks/*" >/tmp/vplex/diskresults-$HOST
) ) 

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

process=( $(
  grep -A1 'name",' /tmp/vplex/diskresults-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/disks-name-$HOST
  grep -A1 'operational-status' /tmp/vplex/diskresults-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/disks-ops-$HOST
  grep 'parent' /tmp/vplex/diskresults-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/disks-parent-$HOST
  paste -d " " /tmp/vplex/disks-parent-$HOST /tmp/vplex/disks-name-$HOST /tmp/vplex/disks-ops-$HOST > /tmp/vplex/diskdata-$HOST
  rm /tmp/vplex/disks-name-$HOST /tmp/vplex/disks-ops-$HOST /tmp/vplex/disks-parent-$HOST /tmp/vplex/diskresults-$HOST
) )

timestamp=( $( echo "Timestamp `date` (online)" >> /tmp/vplex/diskdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "online" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/diskdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "Disks OK"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/diskdata-$HOST
  exit 0
fi

