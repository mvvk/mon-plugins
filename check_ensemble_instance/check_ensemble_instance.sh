#!/bin/bash
# check_ensemble_instance - v1 2014-09-29 MIK

INSTANCE=$1
RESULTFILE=/home/op5mon/ccontrol-result-$INSTANCE
IFS='
'

if [[ $INSTANCE == "debug" ]]; then
  echo "List of all instances."
  ccontrol list
  exit 0
fi

ccontrol list $INSTANCE >$RESULTFILE

STATUS=`grep status /home/op5mon/ccontrol-result-$INSTANCE |awk '{print $2}' |tr -d ','`
STATE=`grep state /home/op5mon/ccontrol-result-$INSTANCE |awk '{print $2}' |tr -d ','`

errors=0

if [[ $STATUS == "running" ]]; then
  errors=0
elif [[ $STATE == "ok" ]]; then
  errors=0
else
  errors=1
fi

if [ $errors -gt 0 ]; then
  echo "Ensemble instance $INSTANCE: problems!"
  cat /home/op5mon/ccontrol-result-$INSTANCE
  exit 2
else
  echo "Ensemble instance $INSTANCE: OK"
  cat /home/op5mon/ccontrol-result-$INSTANCE
  exit 0
fi

