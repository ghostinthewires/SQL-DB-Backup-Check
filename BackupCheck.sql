;WITH CTE_Backup AS
(
SELECT  database_name,backup_start_date,type,physical_device_name
       ,Row_Number() OVER(PARTITION BY database_name,BS.type
        ORDER BY backup_start_date DESC) AS RowNum
FROM    msdb..backupset BS
JOIN    msdb.dbo.backupmediafamily BMF
ON      BS.media_set_id=BMF.media_set_id
)
SELECT      D.name
           ,ISNULL(CONVERT(VARCHAR,backup_start_date),'No backups') AS last_backup_time
           ,D.recovery_model_desc
           ,state_desc,
            CASE WHEN type ='D' THEN 'Full database'
            WHEN type ='I' THEN 'Differential database'
            WHEN type ='L' THEN 'Log'
            WHEN type ='F' THEN 'File or filegroup'
            WHEN type ='G' THEN 'Differential file'
            WHEN type ='P' THEN 'Partial'
            WHEN type ='Q' THEN 'Differential partial'
            ELSE 'Unknown' END AS backup_type
           ,physical_device_name
FROM        sys.databases D
LEFT JOIN   CTE_Backup CTE
ON          D.name = CTE.database_name
AND         RowNum = 1
ORDER BY    D.name,type