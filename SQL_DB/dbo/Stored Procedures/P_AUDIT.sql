-- select * from [dbo].[AUDIT] -- truncate table [dbo].[AUDIT]  
CREATE PROCEDURE [dbo].[P_AUDIT]   
(@TableName  varchar(255) )
AS
--====================================================================
--Created: 13-Sep-2022                           Altered: 13-Sep-2022      
--====================================================================
--Logs any table data changes into table [dbo].[Audit]
--This procedure can ONLY be launched inside a trigger created for table to be logged
--ATTENTION logged table MUST HAVE PrimaryKey!
/*
ALTER TRIGGER [dbo].[TR_FCT_SET_FLEET] ON [dbo].[FCT_SET_FLEET] FOR INSERT, UPDATE, DELETE 
AS  
DECLARE @TableName  varchar(255) ;
--Get the name of the current table where trigger is launched
--@@PROCID	returns the name of currect object (in this case it is trigger name, by which we find table name
SELECT  @TableName = object_name(parent_id) FROM  sys.triggers where object_id = @@PROCID	
--Save data from trigger system-tables(that can be seen in trigger ONLY) into temp tables to be used in procedure later
SELECT * INTO #ins FROM inserted ; SELECT * INTO #del FROM deleted ;
--Run procedure that logs data for the given table. This procedure uses table #ins and #del created above
EXEC [dbo].[P_AUDIT] @TableName ; 
GO
----------------------------------------------------------------------
-- The sql-script in procedure was inspired by the article below, that says about usefull tricks for logging functionality
-- https://www.red-gate.com/simple-talk/databases/sql-server/database-administration-sql-server/pop-rivetts-sql-server-faq-no-5-pop-on-the-audit-trail/

*/
--====================================================================
BEGIN
 SET NOCOUNT ON;

 DECLARE @Bit INT  
        ,@Field INT  
        ,@MaxField INT  
        ,@Char INT 
        ,@FieldName VARCHAR(128) 
        ,@PKCols VARCHAR(1000) 
        ,@SqlCmd VARCHAR(2000)
        ,@LogTime VARCHAR(21) 
        ,@LogUser VARCHAR(128) 
        ,@ActionType CHAR(1) 
        ,@PKSelect VARCHAR(1000)
		,@ErrMsg VARCHAR(1000) ;
 --Note: temp table #ins and #del are created in a fact-table's TRIGGER that launches this proc.
 DECLARE @RowNumInserted bit = case when exists(select top 1 val=1  from #ins) then 1 else 0 end;
 DECLARE @RowNumDeleted bit  = case when exists(select top 1 val=1  from #del) then 1 else 0 end;

 IF @RowNumInserted = 1 and @RowNumDeleted = 1 set @ActionType = 'U';
 IF @RowNumInserted = 0 and @RowNumDeleted = 1 set @ActionType = 'D';
 IF @RowNumInserted = 1 and @RowNumDeleted = 0 set @ActionType = 'I';
  -- date and user
 SELECT @LogUser = SYSTEM_USER ,@LogTime = CONVERT(VARCHAR(8), GETDATE(), 112) + ' ' + CONVERT(VARCHAR(12), GETDATE(), 114)
 -- Get primary key columns for full outer join
 SELECT @PKCols = COALESCE(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
      INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
 WHERE pk.TABLE_NAME = @TableName
       AND CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND c.TABLE_NAME = pk.TABLE_NAME
       AND c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME ;

 -- Get primary key select for insert
 SELECT @PKSelect = COALESCE(@PKSelect+'+','') 
                  + '''<' + COLUMN_NAME + '=''+convert(varchar(255), coalesce(i.' 
                  + COLUMN_NAME +',d.' + COLUMN_NAME + ')) + ''>'''
 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
      INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
 WHERE pk.TABLE_NAME = @TableName
   AND CONSTRAINT_TYPE = 'PRIMARY KEY'
   AND c.TABLE_NAME = pk.TABLE_NAME
   AND c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME ;

 IF @PKCols IS NULL
 BEGIN
     SET @ErrMsg = N'Error raised in [dbo].[P_AUDIT]'  + N': No PK on table = ' + @TableName ;
   --RAISERROR('no PK on table %s', 16, -1, @TableName)
     EXEC [dbo].[P_LOG_ERROR] @ErrMsg, N'Error raised in [dbo].[P_AUDIT]' ;
						--ALTER PROCEDURE [dbo].[P_LOG_ERROR]
						--(@ERR_DESC      nvarchar(1000)
						--,@SOURCE_OBJECT nvarchar(255)
						--,@SOURCE_USER   nvarchar(255) = NULL)
   RETURN
 END

 SELECT @Field = 0, @MaxField = MAX(ORDINAL_POSITION)
 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName ;

 WHILE @Field < @MaxField
 BEGIN
       SELECT @Field = MIN(ORDINAL_POSITION) FROM INFORMATION_SCHEMA.COLUMNS
       WHERE TABLE_NAME = @TableName  AND ORDINAL_POSITION > @Field ;
       SELECT @Bit = (@Field - 1 )% 8 + 1;
       SELECT @Bit = POWER(2,@Bit - 1);
       SELECT @Char = ((@Field - 1) / 8) + 1;

       IF SUBSTRING(COLUMNS_UPDATED(),@Char, 1) & @Bit > 0 OR @ActionType IN ('I','D','U')
       BEGIN
          SELECT @FieldName = COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_NAME = @TableName AND ORDINAL_POSITION = @Field;

          SELECT @SqlCmd = 'INSERT [dbo].[AUDIT] (ACTION_TYPE,TABLE_NAME,PK_VALUE,COLUMN_NAME,OLD_VALUE,NEW_VALUE,LOG_TIME,LOG_USER)'
                         + 'SELECT ''' + @ActionType + ''',''' + @TableName + ''',' + @PKSelect + ',''' + @FieldName + ''''
                         + ',CONVERT(varchar(1000),d.' + @FieldName + ')' + ', CONVERT(varchar(1000),i.' + @FieldName + ')'
                         + ',''' + @LogTime + ''''  + ',''' + @LogUser + ''''
                         + ' FROM #ins i FULL OUTER JOIN #del d' + @PKCols
                         + ' WHERE i.' + @FieldName + ' <> d.' + @FieldName
                         + ' OR (i.' + @FieldName + ' IS NULL AND  d.' + @FieldName + ' IS NOT NULL)'
                         + ' OR (i.' + @FieldName + ' IS NOT NULL AND  d.' + @FieldName  + ' IS NULL)';
          EXEC (@SqlCmd);
       END
 END

 SET NOCOUNT OFF;
END

