# internal-backup-with-folder-sync


This script backs up a user's home folder, and then syncs the Desktop, Downloads, and Dropbox folders on the backup with the ones in the user's home folder.                                       

It allows for the Desktop, Downloads, and Dropbox folders to be working spaces, where files can be stored temporarily, without cluttering up the backup with temporary projects. Basically, I wanted an automated backup that allowed me to delete files from each of those folders, and have those same files automatically removed from the backup.


It logs the backup, and keeps a rotating set of those logs, in case they are needed for troubleshooting. It then optionaly send an email to the user with a copy of the backup log.

The username and path to the backup directory need to be entered added manually in the script. I've tried to make sure those sections were marked clearly.

It can be run manually, but it was meant to be run by anacron, or as a cron job. If it is placed inin /etc/cron.daily, /etc/cron.weekly, or /etc/cron.monthly, the .sh will probably need to be removed from the file name, because run-parts doesn't like the dot in the filename. 

Since the mail command relies on mailutils being installed that part has been left commented out.

If you have mailutils installed, and want to be sent an email on the local machine with a copy of the backup log, uncomment the mail command that is at the end.
