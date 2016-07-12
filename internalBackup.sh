#!/bin/bash

##########################################################################
# This script backs up a user's home folder, and then syncs              #
# the Desktop, Downloads, and Dropbox folders on the backup with the     #
# one's in the user's home folder.                                       #
#                                                                        #
# It allows for the Desktop, Downloads, and Dropbox folders to be        # 
# working spaces, where files can be stored temporarily, without         #
# cluttering up the backup with temporary projects.                      #
#                                                                        #
# It logs the backup, and keeps a rotating set of those logs, in case    #
# they are needed for troubleshooting.                                   #
#                                                                        #
# It then optionaly send an email to the user with a copy of the         #
# backup log.                                                            #
#                                                                        # 
# Since the mail command relies on mailutils being installed that part   #
# has been left commented out.                                           #
#                                                                        #
# If you have mailutils installed, and want to be sent an email on the   #
# local machine with a copy of the backup log, uncomment the mail        #
# command that is at the end.                                            #
##########################################################################




#########################################################################
# Here is where you enter the path of the backup directory.             #
#                                                                       #
# Enter the path to the backup directory after the equals sign.         #
# It should look something like:                                        #
# backupPath=/media/backupdrive/backupfolder                            #
#########################################################################

backupPath=/Enter/the/path/to/the/backup/folder/here



###########################################################################
# Here is where you enter the username for the user who's home directory  #
# is being backed up.                                                     #
#                                                                         #
# It should look something like:                                          #
# username=yourusername                                                   #
###########################################################################

username=enterYourUsernameHere


###########################################################################
# The groupname variable is used for file ownership purposes only.        #
# It is used to set the group permissions for the backup files.  Since    #
# this is for backing up the home directory of a single user, in most     #
# cases the group will be the same as the username.                       #
#                                                                         #
# However, if it does need to be changed, it should look something like:  #
# groupname=nameofgroup                                                   #
###########################################################################

groupname=$username



dateTime=$(date +"%m-%d-%y %H:%M")
address=$username@$(hostname)

###########################################################################
# This sets the path and name of the backup log. If it is being run       #
# by anacron, or from cron.daily, cron.weekly, or cron.monthly, the path  #
# probably won't need to be changed,                                      #
#                                                                         #
# If it is run manually by a user, or if it is run from a user's crontab  #
# the path might need to be set somewhere in the user's home directory    #
#                                                                         #
# An example alternate:                                                   #
# backupLog=~/.log/internalBackup.log                                     #
###########################################################################                 

backupLog=/var/log/internalBackup.log





########################################################################### 
#                                                                         #
#                  This part rotates the backup logs                      #
#                                                                         #
###########################################################################

# The variable i is the loop counter and the maximum 
# number of copies of the backup log

i=5

# if the $i version of the backup log exists
# delete it
if [ -e $backupLog.$i ]
then 
	rm $backupLog.$i;
fi

# Rotate numbered copies of the backup log 
while [ $i -gt 0 ] 
do
	if [ -e $backupLog.$i ]
	then
		# x = i + 1 
		x=$((i + 1)) 
		mv $backupLog.$i $backupLog.$x;
	fi
	# Decrements $i 
	i=$(( $i - 1 ))
done;


#######################################################################
# If the backup log exists, then move it to backupLog.1               #
# to begin the rotation.                                              #
# I should probably put the whole log rotation section in an          #
# if statement, but the mv backupLog backupLog.1  command still       #
# has to happen at the end.                                           #
#######################################################################

if [ -e $backupLog ]
then 
	mv $backupLog $backupLog.1; 	 
fi



####  Begin rsync backup
####  This is where the heavy lifting is done.

echo "This is the log for the backup on $dateTime" > $backupLog
echo >> $backupLog

echo "##############################################" >> $backupLog
echo "###" Beginning the main part of the backup "###" >> $backupLog
echo "##############################################" >> $backupLog
echo  >> $backupLog

rsync -rbulv --exclude=".*" /home/$username/ $backupPath >> $backupLog

echo  >> $backupLog
echo "########################################"  >> $backupLog
echo "###" Cleaning up Desktop backup files "###"  >> $backupLog
echo "########################################"  >> $backupLog
echo  >> $backupLog

rsync -rbulv --exclude=".*" --delete-excluded /home/$username/Desktop/ $backupPath/Desktop/ >> $backupLog 

echo  >> $backupLog
echo "##########################################"  >> $backupLog
echo "###" Cleaning up Downloads backup files "###"  >> $backupLog
echo "##########################################"  >> $backupLog
echo  >> $backupLog

rsync -rbulv --exclude=".*" --delete-excluded /home/$username/Downloads/ $backupPath/Downloads/ >> $backupLog

echo  >> $backupLog
echo "#########################################"  >> $backupLog
echo "###" Cleaning up Dropbox backup files "###"  >> $backupLog
echo "#########################################"  >> $backupLog
echo  >> $backupLog

rsync -rbulv --exclude=".*" --delete-excluded /home/$username/Dropbox/ $backupPath/Dropbox/ >> $backupLog




####################################################################################
# If this is run by anacron or if it is run from cron.daiy, cron.weekly, or        #
# cron.monthly, it might cause the owner and group of the backup files to be       #
# set as root.                                                                     #
#                                                                                  #
# This sets the owner and group to what is listed in the $username and $groupname  #
####################################################################################

chown -R $username:$groupname $backupPath




######################################################################################
# This sends an email message with a copy of the most recent backup log to the user  # 
# listed in the $username variable on the localhost.                                 #
#                                                                                    #
# Since it requires mailutils to be installed, it is commented out, so it doesn't    #
# break the script if mailutils isn't installed.                                     #
#                                                                                    #
# If you have the mailutils installed, and want an email of the backup log sent to   #
# your user account, uncomment the line with the mail command.                       #
######################################################################################

# mail -t $address -s "Internal Backup Log" < $backupLog

