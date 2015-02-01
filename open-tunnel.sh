#!/bin/bash

source capture.conf

echo `date`

PID=`ps -ef | grep -v grep | grep ServerAliveInterval | awk '{ print $2 }'`

if [ -n "$PID" ]
then
  echo "closing existing ssh tunnel to remote host..."
  kill -9 $PID
fi

echo "opening ssh tunnel to remote host..."
ssh -o 'ServerAliveInterval 60' -i $IDENTITY_FILE -N -R 2222:localhost:22 $REMOTE_HOST