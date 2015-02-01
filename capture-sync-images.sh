#!/bin/bash

source capture.conf

if [[ -z "$1" ]]
then
  echo "usage: $0 OUTPATH HOURS ROTATE"
  exit 1
else
  OUTPATH=$1
fi

if [[ -z "$2" ]]
then
  HOURS=1
else
  HOURS=$2
fi

if [[ -z "$3" ]]
then
  EX="-ex auto"
else
  EX="-ex $3"
fi

# find hard drive
echo "finding hard drive..."
DISK=`sudo fdisk -l | grep $DISK_GREP | awk '{ print $1 }'`

if [[ -z $DISK ]]
then
  echo "can't find hard drive!"
  sudo fdisk -l
  echo "exiting..."
  exit 1
else
  echo "hard drive found at $DISK"
fi

# mount hard drive
echo "mounting hard drive..."
sudo mount $DISK /mnt/hd

# mount remote directory
echo "mounting remote server..."
sshfs -o idmap=user ubuntu@$REMOTE_HOST:$REMOTE_PATH/incoming $LOCAL_REMOTE_MOUNT -o IdentityFile=$IDENTITY_FILE

# sync image capture outpath with remote mount point
echo "syncing image capture outpath with remote mount point..."

screen -dmS sync
screen -r sync -X stuff "./sync-images.sh $OUTPATH
"

TIME=$(($HOURS * 60 * 60 * 1000))

# begin capture
echo "capturing $HOURS hour(s) of photos..."
raspistill $EX -o $OUTPATH/image_%06d.jpg -tl 6000 -t $TIME -n

echo "complete!"

# kill image sync (and wait for it to die)
echo "stop syncing image capture outpath with remote mount point..."
screen -S sync -X quit
while screen -list | grep -q sync; do
  sleep 1
done
sleep 3

# unmount remote mount point
echo "unmounting remote server..."
sudo fusermount -u /home/pi/cloudvision-remote

# wait
echo "waiting..."
sleep 3

# unmount hard drive
echo "unmounting hard drive..."
sudo umount /mnt/hd

echo "finished"
