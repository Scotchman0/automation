#!/bin/bash
#https://cloud.google.com/compute/docs/disks/add-persistent-disk

#script to mount volumes and update /etc/fstab

# optionally get MOUNTPOINT from command line argument
if [ $# -eq 1 ]
  then
    MOUNTPATH=$1
  else
    MOUNTPATH=/mnt/disks/data
fi

echo "this script must be run with sudo, press return to continue or ctrl+c to abort and retry with elevated permissions"
read dummyfile

echo "mountpoint set to $MOUNTPATH"

#checks to see if mountpoint exists, if it does not, it creates it, if it does, it unmounts that path to ensure we don't overwrite an existing mount

if [[ ! -d "$MOUNTPATH" ]]
then
  mkdir -p $MOUNTPATH
else
  echo "mountpoint /mnt/disks/data found"
  umount $MOUNTPATH
fi

#print content of volumes available to mount:
lsblk | grep sd
echo "from above list, please specify which volume we are working with:"
echo "example: sdb || sdb1 || sdc (do not include /dev/)"
read VOL

#see if there's a filesystem on the partition or not:
FSCONFIRM=$(sudo lsblk -f | grep $VOL | awk {'print $2'})

#walkthrough provisioning a filesystem if not found; paritition the volume and then mount it; otherwise mount the target
if [[ -z "$FSCONFIRM" ]]
  then echo "no filesystem found on target volume, would you like to create a new one? Y/n (WARNING, EXISTING DATA ON DISK WILL BE WIPED)"
    read answer
    case $answer in 
      y|Y|yes|Yes)
        echo "beginning parted script configuration; abort at any time with ctrl+c"
        echo "confirm again the volume; currently we are looking at $VOL, insert the volume again and press return"
        read VOL
        echo "looking at /dev/$VOL"
        echo "insert partition start (example, 1MB) and press return to contine"
        read START
        echo "insert partition end block or percentage to fill (example, 100%) and press return to continue"
        read END
        echo "insert filesystem type (example ext4) and press return to continue"
        read FSTYPE
        echo "REVIEW YOUR CHANGES:"
        echo "selected disk: /dev/$VOL, partition start: $START, partition end: $END, Filesystem: $FSTYPE"
        echo "press return to commit changes to disk (WARNING, DATA ON DISK WILL BE WIPED), or press Ctrl+c to abort"

        #using partition selections, run parted and configure disk
        parted -s -a optimal /dev/$VOL mklabel gpt -- mkpart primary $FSTYPE $START $END

        #print current changes
        echo "new partition map after disk updates:"
        lsblk | grep sd

        #update value to point now at partition:
        VOL=${VOL}1
        
        #apply filesystem:
        mkfs.${FSTYPE} /dev/${VOL}

        #confirm filesystem applied
        echo ""
        echo "checking that filesystem was applied successfully, printing filesystem info for ${VOL}"
        sudo lsblk -f | grep $VOL | awk {'print $2'}
        echo ""

        #mount the volume:
        echo "proceeding to mount target (new partition) /dev/${VOL} to ${MOUNT}"
  	    mount -o discard,defaults /dev/${VOL} $MOUNTPATH
      ;;
      n|N|no|No) echo "making no changes to disk, attempting to mount regardless as per selection"
        mount -o discard,defaults /dev/${VOL} $MOUNTPATH
        sleep 1
      ;;
    esac
  else echo "filesystem found, proceeding to mount target to ${MOUNT}"
  	mount -o discard,defaults /dev/${VOL} $MOUNTPATH
fi

#checking that target is mounted at path for validation before appendation to fstab

if [[ -z $(df -h | grep /dev/${VOL}) ]]
  then echo "volume failed to mount, aborting"
    exit 1
  else
  	  echo "volume mapped successfully"
      #gather uuid handler for VOL
  	  IFS=\" read -r _ vUUID _ vPARTUUID _ < <(blkid /dev/$VOL -s UUID -s PARTUUID)
  	  if grep -q "$vUUID" "/etc/fstab"
       then 
         echo "/etc/fstab already includes target uuid, skipping append, moving to mount"
       else
         echo "appending /etc/fstab with mount string"
         echo "UUID=$vUUID $MOUNTPATH auto discard,defaults,nofail 0 2" >> /etc/fstab
      fi
  	  echo "unmounting/remounting with fstab config"
  	  umount $MOUNTPATH
  	  sleep 1
  	  mount -a
fi

echo "script complete, please validate via the below confirmation output:"
echo "df -h:"
df -h | grep /dev/${VOL}
echo "fstab:"
cat /etc/fstab | grep $vUUID

exit 0
