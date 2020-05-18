#!/bin/bash

PROC=$1
ACTION=$2
INTERVAL=$3

ps -C $PROC > /dev/null 2>&1
RETV=$?
if [ $ACTION == "started" ]; then
  while [ $RETV -ne 0 ]; do
    echo "Waiting for $PROC started."
    sleep $INTERVAL
    ps -C $PROC > /dev/null 2>&1
    RETV=$?
  done
else
  while [ $RETV -eq 0 ]; do
    echo "Waiting for $PROC terminated."
    sleep $INTERVAL
    ps -C $PROC > /dev/null 2>&1
    RETV=$?
  done
fi
