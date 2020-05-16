#!/bin/bash

WM='icewm'
ps aux | grep $WM | grep -v grep
RETV=$?
while [ $RETV -ne 0 ]
do
  sleep 1
  ps aux | grep $WM | grep -v grep
  RETV=$?
done
