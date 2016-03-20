;WITH CTE_Backup AS
(
SELECT   database_name,backup_start_date,type,is_readonly,physical_device_name
        ,Row_Number() OVER(PARTITION BY database_name,BS.type
         ORDER BY backup_start_date DESC) AS RowNum
FROM     msdb..backupset BS
JOIN     msdb.dbo.backupmediafamily BMF
ON       BS.media_set_id=BMF.media_set_id
WHERE    type='L'
)
SELECT      D.name
           ,ISNULL(CONVERT(VARCHAR,backup_start_date),'No log backups') AS last_backup_time
           ,D.recovery_model_desc
           ,state_desc
           ,physical_device_name
FROM        sys.databases D
LEFT JOIN   CTE_Backup CTE
ON          D.name = CTE.database_name
AND         RowNum = 1
WHERE       ( backup_start_date IS NULL OR backup_start_date < DATEADD(dd,-1,GetDate()) )
AND         recovery_model_desc != 'SIMPLE'
ORDER BY    D.name,type