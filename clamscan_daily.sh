#!/bin/bash
LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log";
EMAIL_MSG="Alert - a file has been flagged as infected, and moved to /quarantine - review log in ${LOGFILE}";
EMAIL_FROM="root@$(hostname)";
EMAIL_TO="root";
DIRTOSCAN="/home /var /tmp /etc /run /opt";
#DIRTOSCAN="/tmp";

touch ${LOGFILE}

for S in ${DIRTOSCAN}; do
 DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);

 echo "Starting a daily scan of "$S" directory.
 Amount of data to be scanned is "$DIRSIZE".";

 #run the scan on the directories:
 clamscan -ri --move=/quarantine "$S" >> "${LOGFILE}";

 #set permissions on all items in /quarantine:
 chmod -R 400 /quarantine/*

 # get the value of "Infected lines"
 MALWARE=$(tail "${LOGFILE}"|grep Infected|cut -d" " -f3);

 # if the value is not equal to zero, send an email with the log file attached
 if [ "${MALWARE}" -ne "0" ];then
 # using heirloom-mailx below
 echo "${EMAIL_MSG}"|mail -s "Malware Found" -r "${EMAIL_FROM}" "${EMAIL_TO}";
 fi
done

#cleanup logs:
find /var/log/clamav/ -name "*.log" -type f -mtime +30 -delete
find /var/log/clamav/ -name "*.gz" -type f -mtime +30 -delete

exit 0
