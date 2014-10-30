#!/bin/bash

# Quick-n-dirty Nagios plugin for curl with NTLM auth support
# Mikko Koivunen (last edit 2014-10-30)

USERID=$1
PASSWD=$2
URL=$3
STRING=$4

query_string () {
    curl --ntlm -u "$USERID:$PASSWD" $URL -sq |grep $STRING |wc -l
}

query_status () {
    curl --ntlm -u "$USERID:$PASSWD" -w "Returned HTTP Status code: \"%{http_code}\" (Should be 200). |http_code=%{http_code}; time=%{time_total}\n" $URL -sq -o /dev/null
}

QUERYRESULT=`query_string`
QUERYSTATUS=`query_status`

if [[ "$QUERYRESULT" = "0" ]]; then
    echo String "$STRING" not found!
    echo $QUERYSTATUS
    exit 1

else
    echo String "$STRING" found.
    echo $QUERYSTATUS
    exit 0
fi

