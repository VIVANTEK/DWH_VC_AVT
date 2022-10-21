
CREATE PROCEDURE [dbo].[P_UPDATE_FCT_SET_FLEET]         
AS
--===========================================================================
--Created: 16-Aug-2022                                  Altered: 16-Aug-2022       
--===========================================================================
--This procedure is used in trigger for writeback-table [dbo].[WRB_SET_FLEET]
--It transfer data from [dbo].[WRB_SET_FLEET] to table [dbo].[FCT_SET_FLEET]
--===========================================================================
/*
 exec sp_recompile '[dbo].[P_UPDATE_FCT_SET_FLEET] ' 
 --------------------------------------------------------------------
 SELECT * FROM [dbo].[V_WRB_SET_FLEET]
 SELECT * FROM [dbo].[FCT_SET_FLEET]
 EXEC [dbo].[P_UPDATE_FCT_SET_FLEET] 
 --------------------------------------------------------------------
 --TRUNCATE TABLE [dbo].[WRB_SET_FLEET]
 --select * from [dbo].[LOG_SET_FLEET] 
 --truncate table [dbo].[LOG_SET_FLEET]
 --------------------------------------------------------------------
*/
--=====================================================================

BEGIN
SET NOCOUNT ON; 
BEGIN TRY 

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ LOG DATA @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Log updated 'CONSUMPTION_CHARTER' data 
  INSERT INTO [dbo].[LOG_SET_FLEET]
        ([TRANSPORT_CODE],[MONTH_ID],[FLD_NAME],[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER])
  SELECT SRC.[TRANSPORT_CODE],SRC.[MONTH_ID]
       , [FLD_NAME] = 'CONSUMPTION_CHARTER'
       , [OLD_VALUE] = ISNULL(DST.[CONSUMPTION_CHARTER],0)
       , [NEW_VALUE] = ISNULL(SRC.[CONSUMPTION_CHARTER],0) + ISNULL(DST.[CONSUMPTION_CHARTER],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_SET_FLEET] AS SRC
  LEFT JOIN [dbo].[FCT_SET_FLEET] AS DST
  ON  SRC.[TRANSPORT_CODE] = DST.[TRANSPORT_CODE]
  AND SRC.[MONTH_ID]       = DST.[MONTH_ID]
  WHERE ISNULL(DST.[CONSUMPTION_CHARTER],0)  <>  ISNULL(SRC.[CONSUMPTION_CHARTER],0) + ISNULL(DST.[CONSUMPTION_CHARTER],0)
  --=========================================================================================
--Log updated 'CONSUMPTION_DOMESTIC' data 
  INSERT INTO [dbo].[LOG_SET_FLEET]
        ([TRANSPORT_CODE],[MONTH_ID],[FLD_NAME],[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER])
  SELECT SRC.[TRANSPORT_CODE],SRC.[MONTH_ID]
       , [FLD_NAME] = 'CONSUMPTION_DOMESTIC'
       , [OLD_VALUE] = ISNULL(DST.[CONSUMPTION_DOMESTIC],0)
       , [NEW_VALUE] = ISNULL(SRC.[CONSUMPTION_DOMESTIC],0) + ISNULL(DST.[CONSUMPTION_DOMESTIC],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_SET_FLEET] AS SRC
  LEFT JOIN [dbo].[FCT_SET_FLEET] AS DST
  ON  SRC.[TRANSPORT_CODE] = DST.[TRANSPORT_CODE]
  AND SRC.[MONTH_ID]       = DST.[MONTH_ID]
  WHERE ISNULL(DST.[CONSUMPTION_DOMESTIC],0)  <>  ISNULL(SRC.[CONSUMPTION_DOMESTIC],0) + ISNULL(DST.[CONSUMPTION_DOMESTIC],0)
  --=========================================================================================
--Log updated 'CONSUMPTION_INTERNATIONAL' data 
  INSERT INTO [dbo].[LOG_SET_FLEET]
        ([TRANSPORT_CODE],[MONTH_ID],[FLD_NAME],[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER])
  SELECT SRC.[TRANSPORT_CODE],SRC.[MONTH_ID]
       , [FLD_NAME] = 'CONSUMPTION_INTERNATIONAL'
       , [OLD_VALUE] = ISNULL(DST.[CONSUMPTION_INTERNATIONAL],0)
       , [NEW_VALUE] = ISNULL(SRC.[CONSUMPTION_INTERNATIONAL],0) + ISNULL(DST.[CONSUMPTION_INTERNATIONAL],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_SET_FLEET] AS SRC
  LEFT JOIN [dbo].[FCT_SET_FLEET] AS DST
  ON  SRC.[TRANSPORT_CODE] = DST.[TRANSPORT_CODE]
  AND SRC.[MONTH_ID]       = DST.[MONTH_ID]
  WHERE ISNULL(DST.[CONSUMPTION_INTERNATIONAL],0)  <>  ISNULL(SRC.[CONSUMPTION_INTERNATIONAL],0) + ISNULL(DST.[CONSUMPTION_INTERNATIONAL],0)
  --=========================================================================================
--Log updated 'WEIGHT_CAPACITY' data 
  INSERT INTO [dbo].[LOG_SET_FLEET]
        ([TRANSPORT_CODE],[MONTH_ID],[FLD_NAME],[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER])
  SELECT SRC.[TRANSPORT_CODE],SRC.[MONTH_ID]
       , [FLD_NAME] = 'WEIGHT_CAPACITY'
       , [OLD_VALUE] = ISNULL(DST.[WEIGHT_CAPACITY],0)
       , [NEW_VALUE] = ISNULL(SRC.[WEIGHT_CAPACITY],0) + ISNULL(DST.[WEIGHT_CAPACITY],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_SET_FLEET] AS SRC
  LEFT JOIN [dbo].[FCT_SET_FLEET] AS DST
  ON  SRC.[TRANSPORT_CODE] = DST.[TRANSPORT_CODE]
  AND SRC.[MONTH_ID]       = DST.[MONTH_ID]
  WHERE ISNULL(DST.[WEIGHT_CAPACITY],0)  <>  ISNULL(SRC.[WEIGHT_CAPACITY],0) + ISNULL(DST.[WEIGHT_CAPACITY],0)
  --=========================================================================================
--Log updated 'MTOW' data 
  INSERT INTO [dbo].[LOG_SET_FLEET]
        ([TRANSPORT_CODE],[MONTH_ID],[FLD_NAME],[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER])
  SELECT SRC.[TRANSPORT_CODE],SRC.[MONTH_ID]
       , [FLD_NAME] = 'MTOW'
       , [OLD_VALUE] = ISNULL(DST.[MTOW],0)
       , [NEW_VALUE] = ISNULL(SRC.[MTOW],0) + ISNULL(DST.[MTOW],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_SET_FLEET] AS SRC
  LEFT JOIN [dbo].[FCT_SET_FLEET] AS DST
  ON  SRC.[TRANSPORT_CODE] = DST.[TRANSPORT_CODE]
  AND SRC.[MONTH_ID]       = DST.[MONTH_ID]
  WHERE ISNULL(DST.[MTOW],0)  <>  ISNULL(SRC.[MTOW],0) + ISNULL(DST.[MTOW],0)

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MERGE DATA @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Synchronize the target table with refreshed data from source table
  MERGE [dbo].[FCT_SET_FLEET]   AS TRG
  USING [dbo].[V_WRB_SET_FLEET] AS SRC 
  ON  TRG.[TRANSPORT_CODE]  = SRC.[TRANSPORT_CODE]
  AND TRG.[MONTH_ID]        = SRC.[MONTH_ID]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When records are matched, update the records if there is any change
  WHEN MATCHED  THEN UPDATE SET  
       TRG.[CONSUMPTION_CHARTER]       = ISNULL(TRG.[CONSUMPTION_CHARTER],0)       + ISNULL(SRC.[CONSUMPTION_CHARTER],0)   
      ,TRG.[CONSUMPTION_DOMESTIC]      = ISNULL(TRG.[CONSUMPTION_DOMESTIC],0)      + ISNULL(SRC.[CONSUMPTION_DOMESTIC],0)   
      ,TRG.[CONSUMPTION_INTERNATIONAL] = ISNULL(TRG.[CONSUMPTION_INTERNATIONAL],0) + ISNULL(SRC.[CONSUMPTION_INTERNATIONAL],0)   
      ,TRG.[WEIGHT_CAPACITY]           = ISNULL(TRG.[WEIGHT_CAPACITY],0)           + ISNULL(SRC.[WEIGHT_CAPACITY],0)   
      ,TRG.[MTOW]                      = ISNULL(TRG.[MTOW],0)                      + ISNULL(SRC.[MTOW],0)   
    --,TRG.[LOG_USER] = SRC.[LOG_USER]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When no records are matched, insert the incoming records from SRC table to TRG table
--We insert all measure as NULL except [BDG_ACT_FLG] which is enterd by user
  WHEN NOT MATCHED BY TARGET THEN INSERT 
     ([TRANSPORT_CODE],[MONTH_ID],[CONSUMPTION_CHARTER],[CONSUMPTION_DOMESTIC]
     ,[CONSUMPTION_INTERNATIONAL],[WEIGHT_CAPACITY],[MTOW])  
  VALUES 
     (SRC.[TRANSPORT_CODE],SRC.[MONTH_ID],SRC.[CONSUMPTION_CHARTER],SRC.[CONSUMPTION_DOMESTIC]
     ,SRC.[CONSUMPTION_INTERNATIONAL],SRC.[WEIGHT_CAPACITY],SRC.[MTOW]) ;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When there is a row that exists in TRG and same record does not exist in SRC then delete this record from TRG
--WHEN NOT MATCHED BY SOURCE  THEN DELETE ;
   /*=========================================================================================
  --$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns 
  --one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row
	OUTPUT $action 
    ,DELETED.[TRANSPORT_CODE]     AS [TRANSPORT_CODE]
    ,DELETED.[MONTH_ID]        AS [MONTH_ID] 
    ,DELETED.[CONSUMPTION_CHARTER]      AS [CONSUMPTION_CHARTER]
	--------------------------------------------------------------
    ,INSERTED.[TRANSPORT_CODE]     AS [TRANSPORT_CODE]
    ,INSERTED.[MONTH_ID]       AS [MONTH_ID] 
    ,INSERTED.[CONSUMPTION_CHARTER]     AS [CONSUMPTION_CHARTER]
   =========================================================================================*/
 --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
  TRUNCATE TABLE [dbo].[WRB_SET_FLEET];
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Delete rows with zero-values from destination table once again in case user just zeroes data
--Otherwise EXCEPT-INSERT-command rnturns no rows. Also this makes table smaller
--DELETE FROM [dbo].[WRB_PROFIT_LOSS] WHERE ISNULL([PNL_AMOUNT],0) = 0 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
END TRY 
BEGIN CATCH 
  --RAISERROR ('Error raised in [dbo].[pUpdateProductionCubeData_TTL]',16,1);  
  EXEC [dbo].[P_LOG_ERROR] N'Error raised in [dbo].[P_UPDATE_FCT_SET_FLEET]'
                          ,N'[dbo].[P_UPDATE_FCT_SET_FLEET]' ;
  --SELECT * FROM [dbo].[LOG_ERROR]
END CATCH; 
SET NOCOUNT OFF;

END

/*
  WITH WRB AS
  (SELECT [TRANSPORT_CODE],[MONTH_ID]
         ,[FLD_NAME]  = 'CONSUMPTION_CHARTER'
         ,[FLD_VALUE] = [CONSUMPTION_CHARTER]
         ,[LOG_TIME],[LOG_USER]
  FROM [dbo].[V_WRB_SET_FLEET]
  UNION ALL
  SELECT [TRANSPORT_CODE],[MONTH_ID]
        ,[FLD_NAME]  = 'CONSUMPTION_DOMESTIC'
        ,[FLD_VALUE] = [CONSUMPTION_DOMESTIC]
        ,[LOG_TIME],[LOG_USER]
  FROM [dbo].[V_WRB_SET_FLEET]
  UNION ALL
  SELECT [TRANSPORT_CODE],[MONTH_ID]
        ,[FLD_NAME]  = 'CONSUMPTION_INTERNATIONAL'
        ,[FLD_VALUE] = [CONSUMPTION_INTERNATIONAL]
        ,[LOG_TIME],[LOG_USER]
  FROM [dbo].[V_WRB_SET_FLEET]
  UNION ALL
  SELECT [TRANSPORT_CODE],[MONTH_ID]
        ,[FLD_NAME]  = 'WEIGHT_CAPACITY'
        ,[FLD_VALUE] = [WEIGHT_CAPACITY]
        ,[LOG_TIME],[LOG_USER]
  FROM [dbo].[V_WRB_SET_FLEET]
  UNION ALL
  SELECT [TRANSPORT_CODE],[MONTH_ID]
        ,[FLD_NAME]  = 'MTOW'
        ,[FLD_VALUE] = [MTOW]
        ,[LOG_TIME],[LOG_USER]
  FROM [dbo].[V_WRB_SET_FLEET] );
GO

*/