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
  curl -s -k -H Username:$USR -H Password:$PWD "https://$HOST/vplex/clusters/*/" >/tmp/vplex/cluster-results-$HOST
) ) 

if [ $? -ne 0 ]; then
  echo "UNKNOWN: can't get data"
  exit 3
fi

process=( $(
  grep -A1 'name",' /tmp/vplex/cluster-results-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/cluster-name-$HOST
  grep -A1 'operational-status' /tmp/vplex/cluster-results-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/cluster-ops-$HOST
  grep -A1 'health-state' /tmp/vplex/cluster-results-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/cluster-health-$HOST
  grep -A1 'connected' /tmp/vplex/cluster-results-$HOST |grep -v name  |grep -v "^-"  | awk '{ print $2 }'  | tr -d '"' >/tmp/vplex/cluster-conn-$HOST
  paste -d " " /tmp/vplex/cluster-name-$HOST /tmp/vplex/cluster-ops-$HOST /tmp/vplex/cluster-health-$HOST /tmp/vplex/cluster-conn-$HOST > /tmp/vplex/clusterdata-$HOST
  rm /tmp/vplex/cluster-name-$HOST /tmp/vplex/cluster-ops-$HOST /tmp/vplex/cluster-health-$HOST /tmp/vplex/cluster-conn-$HOST
) )

timestamp=( $( echo "Timestamp `date` (ok ok true)" >> /tmp/vplex/clusterdata-$HOST) )

errors=0
while read -r line; do
  if [[ ! $line =~ "ok ok true" ]]; then
  echo "CRITICAL: $line"
  errors=1
  fi 
done </tmp/vplex/clusterdata-$HOST

if [ $errors -gt 0 ]; then
  exit 2
else
  echo "Clusters OK"
  echo "Cluster name, status, health, connected"
  while read -r line; do
    echo "$line"
  done </tmp/vplex/clusterdata-$HOST
  exit 0
fi

