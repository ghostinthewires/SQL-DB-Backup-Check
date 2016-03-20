# Checking when a database was last backed up #

It can be useful to periodically check when each database on a server was last backed up. The easiest way to do this on a single database is to right click on the database in SQL Server Management Studio (SSMS) and looking at the top of the Database Properties page.

However when there are several databases to check this can be quite labourious. SSMS actually uses the system table backupset to populate this part of the Properties page (you can verify this by running SQL Profiler just before opening the page). 

I use the **BackupCheck.sql** script that uses this table along with backupmediafamily system table (to identify the file name of the backup) to query the latest backup of each type. The script query returns the most recent backup of each type, whether it's a full, transaction log, differential, filegroup or partial backup.

As an aside the 'Last Database Backup' shown in SSMS does not seem to include filegroup or partial backups, only full, differential or log backups. I'm not sure why this should be.


## Identifying Databases Which Haven’t Been Backed Up Recently ##

The above script can return a lot of data if your server has many databases, so I've modified it to produce a list of databases that have had no backups in the last 7 days (you might want to change this to a shorter period especially for production databases) 

The **NoBackups.sql** script will produce a list of databases for investigation, though of course there may be a good reason for a database not being backed up, for instance it's not possible to backup database snapshots. Also if the secondary database of a log shipping configuration there's not always a need to back it up. 


## Missing Transaction Log Backups ##

Finally I've modified the above script so that it reports all databases that have the full or bulk-logged recovery model and where there hasn't been a transaction log backup in the last day. This is the **TransLog24.sql** script.

I hope the above queries are of use in identifying databases where there is no recent backup in place. You really don't want to be in a position where this is only discovered when the backup is actually needed, i.e. after a disk failure or data corruption. Of course you should also be checking that your backups are valid, ideally by periodically restoring from a backup, or at the very least by checking the backups using the VERIFYONLY option (though there is really no substitute for doing an actual restore).  