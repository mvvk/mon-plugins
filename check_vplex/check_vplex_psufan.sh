#!/bin/bash
# Bash script to check VPLEX REST API
# Mikko Koivunen, <mikko.koivunen@medbit.fi>

#set -x
HOST=$1
USR=$2
PWD=$3
IFS='
'

status=( $( 
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/power-supplies/*?operational-status" |grep parent | awk '{ print $2 }' | tr -d '"' |tr -d ',' >/tmp/vplex/psu_parent_tmp-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/power-supplies/*?operational-status" |grep value | awk '{ print $2 }' | tr -d '"' >/tmp/vplex/psu_value_tmp-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/fans/*?operational-status" |grep parent | awk '{ print $2 }' | tr -d '"' |tr -d ',' >/tmp/vplex/fan_parent_tmp-$HOST
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/engines/engine-*/fans/*?operational-status" |grep value | awk '{ print $2 }' | tr -d '"' >/tmp/vplex/fan_value_tmp-$HOST
  paste -d " " /tmp/vplex/fan_parent_tmp-$HOST /tmp/vplex/fan_value_tmp-$HOST > /tmp/vplex/envhwdata-$HOST
  paste -d " " /tmp/vplex/psu_parent_tmp-$HOST /tmp/vplex/psu_value_tmp-$HOST >>/tmp/vplex/envhwdata-$HOST
  rm /tmp/vplex/psu_parent_tmp-$HOST /tmp/vplex/psu_value_tmp-$HOST
  rm /tmp/vplex/fan_parent_tmp-$HOST /tmp/vplex/fan_value_tmp-$HOST
) )

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

timestamp=( $( echo "Timestamp `date` (online)" >> /tmp/vplex/envhwdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "online" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/envhwdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "PSU & Fan operational status OK"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/envhwdata-$HOST
  exit 0
fi

