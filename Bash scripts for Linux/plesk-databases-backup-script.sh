#!/bin/bash
#
# This is a low resources backup script we used to use on some servers, to backup databases to a repository within /home
# A second daemon would then replicate this backups folder to a remote repository for better redundancy.
#
# Original script courtesy of Sonia Hamilton
# http://www.snowfrog.net/2005/11/16/backup-multiple-databases-into-separate-files/
#
# Modified by QWeb Ltd to work more securely on Plesk servers, and to keep 2 days of backups instead of just the most recent.
#
# Create /home/database-backups and chmod +x this file to make it executable. Then set it up as a Cron task to run daily.


# Plesk renames root to admin
USER="admin"

# Plesk stores the admin password here
PASSWORD="`cat /etc/psa/.psa.shadow`"

# mkdir this folder if it doesn't yet exist
OUTPUTDIR="/home/database-backups"

MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

# clean up older backups (save space)
rm "$OUTPUTDIR/*bak2" > /dev/null 2>&1

# get a list of databases
databases=`$MYSQL --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

# dump each database in turn
for db in $databases; do
	# maintain backups for 2 days to prevent complete loss if the server dies during this backup process, for example
	mv "$OUTPUTDIR/$db.bak" "$OUTPUTDIR/$db.bak2"

	$MYSQLDUMP --force --opt --user=$USER --password=$PASSWORD --databases $db > "$OUTPUTDIR/$db.bak"
done
