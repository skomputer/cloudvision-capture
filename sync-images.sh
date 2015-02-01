#!/bin/bash

source capture.conf

sudo sshfs -o idmap=user ubuntu@$REMOTE_HOST:$REMOTE_PATH/incoming $LOCAL_REMOTE_MOUNT -o IdentityFile=$IDENTITY_FILE

# get the current path
CURPATH=`pwd`

if [[ -z "$1" ]]
then
  ORIGIN="/mnt/hd/images/camera/new"
else
  ORIGIN=$1
fi

inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' -e move $ORIGIN | while read date time dir file; do

  if [ ${file: -4} == ".jpg" ]
  then

    FILECHANGE=${dir}${file}
    # convert absolute path to relative
    FILECHANGEREL=`echo "$FILECHANGE" | sed 's_'$CURPATH'/__'`

    cp $FILECHANGEREL $LOCAL_REMOTE_MOUNT
    echo "At ${time} on ${date}, file $FILECHANGE was copied to $LOCAL_REMOTE_MOUNT"
  fi

done