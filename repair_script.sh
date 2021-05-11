#!/bin/bash
set -e
usage() {
  echo "bash repair_script.sh [-k keyspace] [-t table ] [-e end_token] [-s start_token]"
  exit 1
}
while getopts k:t:s:e: flag
do
    case "${flag}" in
        k) KEYSPACE=${OPTARG};;
        t) TABLE=${OPTARG};;
        s) START_TOKEN=${OPTARG};;
        e) END_TOKEN=${OPTARG};;
        :)
           echo "Error: -${OPTARG} requires an argument."
           usage
           ;;
        *)
           usage
           ;;
    esac
done
EXTRA_PARAMS=''
if [ ! -z "$KEYSPACE" ] && [ ! -z "$TABLE" ]
then
  echo "Running on keyspace ${KEYSPACE} and table ${TABLE}"
  EXTRA_PARAMS="$EXTRA_PARAMS -- $KEYSPACE $TABLE"
elif [ ! -z "$KEYSPACE" ] && [ -z "$TABLE" ]
then
  echo "Running on keyspace ${KEYSPACE}"
  EXTRA_PARAMS="$EXTRA_PARAMS -- $KEYSPACE"
elif [ -z "$KEYSPACE" ] && [ ! -z "$TABLE" ]
then
  echo "If you specify a table, you need to add also the keyspace"
  exit 1
fi
if [ ! -z "$START_TOKEN" ] && [ ! -z "$END_TOKEN" ]
then
    echo nodetool repair -full -j 1 -pr -st  ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
         nodetool repair -full -j 1 -pr -st  ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
else
    IP_ADDRESS=`sudo netstat -nap | grep 7001 | awk '{print $4}' | grep 7001 | uniq | sed -e 's/:.*//g'`
    DESCRIBERING=`nodetool  describering -- system_auth`
    for st in `nodetool ring  | grep  ${IP_ADDRESS} | awk '{print $8}'`
    do
        TOKEN_RANGE=`echo "$DESCRIBERING" | grep end_token:${st} | sed -e 's/, endpoints.*//g' -e 's/.*TokenRange(//g' -e 's/start_token://g' -e 's/ end_token://g'`
        START_TOKEN=`echo $TOKEN_RANGE | cut -d"," -f1`
        END_TOKEN=`echo $TOKEN_RANGE | cut -d"," -f2`
        if [ -z $START_TOKEN ] || [ -z $END_TOKEN ]
        then
            echo "TOKEN_RANGE= $TOKEN_RANGE"
            exit 1
        fi
        echo nodetool repair -full -j 1 -pr -st  ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
             nodetool repair -full -j 1 -pr -st  ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
        if [ $? -gt 0 ]
        then
            echo Failed execution. Retrying...
            echo nodetool repair -full -j 1 -pr -st  ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
                 nodetool repair -full -j 1 -pr -st  ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
            if  [ $? -gt 0 ]
            then
                echo nodetool command failed again: nodetool repair -full -j 1 -pr -st   ${START_TOKEN} -et ${END_TOKEN} ${EXTRA_PARAMS}
                echo Exiting...
                exit 1
            fi
        fi
    done
fi