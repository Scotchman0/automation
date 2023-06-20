#!/bin/bash
#this script is designed to be executed by cronjob to clean and organize files by date
#objectively, the purpose is to first:
# - define (if not already defined) an archive folder at ~/Downloads/archive
# - create a folder with $(date)-1day as name in ~/Downloads/archive
# - move all content from ~/Downloads (excluding ~/Downloads/archive) into ../archive/${folder}
# - remove any folders in ..archive/* that are older than 30 days
# thereby cleaning the Downloads folder up, but allowing for recovery for some time as needed
# since this will break any symlinks it will force me to save content elsewhere



#variables:
yesterday=$(date +%m_%d_%y -d "1 day ago")
archive_top=~/Downloads/archive
archive_yesterday=${archive_top}/${yesterday}.bak


# define folder structure
if [[ ! -e $archive_top ]]; then
	mkdir -p $archive
elif [[ ! -d $archive_top ]]; then
	echo "$archive already exists but is not a folder"
fi

#create yesterday's downloads folder at ~/Downloads/${archive_top}/${archive_yesterday}
if [[ ! -e $archive_yesterday ]]; then
	mkdir -p $archive_yesterday
elif [[ ! -d $archive_yesterday ]]; then
	echo "$archive_yesterday already exists but is not a folder"
fi

#move all content in downloads (except for the $archive_top structure) into $archive_yesterday
for i in `ls ~/Downloads | grep -v "archive"`; do mv ~/Downloads/${i} ${archive_yesterday}/; done

#remove folders older than 30 days
find ~/Downloads/archive/ -name ".bak" -type d -mtime +30 -delete
echo "removed older than 30 days snapshots from local dir"

#advise cleared
echo "downloads cleared"
