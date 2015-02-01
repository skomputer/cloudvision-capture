#!/bin/bash

source capture.conf

ls -l | grep cloudvision-remote$ | awk '{print $1}' | while read perms; do
  if [ $perms == 'd?????????' ]
  then
    sudo fusermount -u /home/pi/cloudvision-remote
    sshfs -o idmap=user ubuntu@$REMOTE_HOST:$REMOTE_PATH/incoming $LOCAL_REMOTE_MOUNT -o IdentityFile=$IDENTITY_FILE
  fi
done