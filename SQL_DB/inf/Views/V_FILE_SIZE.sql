
CREATE VIEW [inf].[V_FILE_SIZE] 
--========================================================
--Created: 03-Oct-2017               Altered: 05-Feb-2018  
--========================================================
--Shows DB files size for current DB
/*
--run this view
select * from [inf].[V_FILE_SIZE]  with(nolock)
*/
--========================================================
as

SELECT DB_NAME() as [DBName]
      ,@@SERVERNAME AS [ServerName]
      ,fileid=file_id
	  ,groupid = a.data_space_id
	  ,a.name
      ,filename=physical_name
      ,convert(decimal(12,2),round(a.size/128.000,2)) as FileSizeMB
      ,convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)) as SpaceUsedMB
      ,convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)) as FreeSpaceMB
FROM sys.database_files a with(nolock)
  LEFT OUTER JOIN sys.filegroups b with(nolock)
  ON a.data_space_id=b.data_space_id

/*
--old variant which runs too long if the current DB is filled with data. Maybe 'cause it's locked duaring updates
SELECT DB_NAME() as [DBName],
       @@SERVERNAME AS [ServerName],
       fileid, groupid,name,
       filename,
       convert(decimal(12,2),round(a.size/128.000,2)) as FileSizeMB,
       convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)) as SpaceUsedMB,
       convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)) as FreeSpaceMB
FROM dbo.sysfiles a
*/


