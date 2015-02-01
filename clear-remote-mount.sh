#!/bin/bash

source capture.conf

df | grep rootfs | awk '{print $4}' | while read blocks; do
  if [ $blocks -le 200000 ]
  then
    echo `date`
    echo "rootfs has only $blocks blocks free! deleting files from cloudvision-remote..."
    rm $LOCAL_REMOTE_MOUNT/*.jpg
  fi
done