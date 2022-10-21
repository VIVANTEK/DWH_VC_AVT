
CREATE PROCEDURE [dbo].[P_UPDATE_FCT_CFO]         
AS
--===========================================================================
--Created: 20-Aug-2022                                   Altered: 20-Aug-2022         
--===========================================================================
--This procedure is used in trigger for writeback-table [dbo].[WRB_CFO]
--It transfer data from [dbo].[WRB_CFO] to table [dbo].[FCT_CFO]
--===========================================================================
/*
 exec sp_recompile '[dbo].[P_UPDATE_FCT_CFO]' 
 --------------------------------------------------------------------
 SELECT * FROM [dbo].[V_WRB_CFO]
 SELECT * FROM [dbo].[FCT_CFO] 
 EXEC [dbo].[P_UPDATE_FCT_CFO]  
 --------------------------------------------------------------------
 --TRUNCATE TABLE [dbo].[WRB_CFO]
 --select * from [dbo].[LOG_CFO] 
 --truncate table [dbo].[LOG_CFO]
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
  INSERT INTO [dbo].[LOG_CFO] 
        ([PNL_ITEM],[CFO_NAME],[MONTH_ID],[VERSION]--,[LAYER_ID],[FLD_NAME]
        ,[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER])
  SELECT SRC.[PNL_ITEM],SRC.[CFO_NAME],SRC.[MONTH_ID],SRC.[VERSION]--,SRC.[LAYER_ID],[FLD_NAME] = N'PNL_AMOUNT'
       , [OLD_VALUE] = ISNULL(DST.[PNL_AMOUNT],0)
       , [NEW_VALUE] = ISNULL(SRC.[PNL_AMOUNT],0) + ISNULL(DST.[PNL_AMOUNT],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_CFO] AS SRC
  LEFT JOIN [dbo].[FCT_CFO] AS DST
  ON  SRC.[PNL_ITEM] = DST.[PNL_ITEM]
  AND SRC.[CFO_NAME] = DST.[CFO_NAME]
  AND SRC.[MONTH_ID] = DST.[MONTH_ID]
  AND SRC.[VERSION]  = DST.[VERSION]
  AND SRC.[LAYER_ID] = DST.[LAYER_ID]

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MERGE DATA @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Synchronize the target table with refreshed data from source table
  MERGE [dbo].[FCT_CFO]   AS TRG
  USING [dbo].[V_WRB_CFO] AS SRC 
  ON  TRG.[PNL_ITEM]  = SRC.[PNL_ITEM]
  AND TRG.[CFO_NAME]  = SRC.[CFO_NAME]
  AND TRG.[MONTH_ID]  = SRC.[MONTH_ID]
  AND TRG.[VERSION]   = SRC.[VERSION] 
  AND TRG.[LAYER_ID]  = SRC.[LAYER_ID]

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When records are matched, update the records if there is any change
  WHEN MATCHED  THEN UPDATE SET  
       TRG.[PNL_AMOUNT]       = ISNULL(TRG.[PNL_AMOUNT],0)       + ISNULL(SRC.[PNL_AMOUNT],0)   
    --,TRG.[LOG_USER] = SRC.[LOG_USER]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When no records are matched, insert the incoming records from SRC table to TRG table
--We insert all measure as NULL except [BDG_ACT_FLG] which is enterd by user
  WHEN NOT MATCHED BY TARGET THEN INSERT  
         ([PNL_ITEM],[CFO_NAME],[MONTH_ID],[VERSION],[PNL_AMOUNT])                      --,[LAYER_ID])
  VALUES (SRC.[PNL_ITEM],SRC.[CFO_NAME],SRC.[MONTH_ID],SRC.[VERSION],SRC.[PNL_AMOUNT]) ;--,SRC.[LAYER_ID])
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When there is a row that exists in TRG and same record does not exist in SRC then delete this record from TRG
--WHEN NOT MATCHED BY SOURCE  THEN DELETE ;
   /*=========================================================================================
  --$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns 
  --one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row
	OUTPUT $action 
    ,DELETED.[PNL_ITEM]     AS [DEL_PNL_ITEM]
    ,DELETED.[CFO_NAME]     AS [DEL_CFO_NAME]
    ,DELETED.[MONTH_ID]     AS [DEL_MONTH_ID] 
	--------------------------------------------------------------
    ,INSERTED.[PNL_ITEM]    AS [INS_PNL_ITEM]
    ,INSERTED.[CFO_NAMER]   AS [INS_CFO_NAME]
    ,INSERTED.[MONTH_ID]    AS [INS_MONTH_ID] 
   =========================================================================================*/
 --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
  TRUNCATE TABLE  [dbo].[WRB_CFO];
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Delete rows with zero-values from destination table once again in case user just zeroes data
--Otherwise EXCEPT-INSERT-command rnturns no rows. Also this makes table smaller
--DELETE FROM [dbo].[WRB_PROFIT_LOSS] WHERE ISNULL([PNL_AMOUNT],0) = 0 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
END TRY 
BEGIN CATCH 
  --RAISERROR ('Error raised in [dbo].[pUpdateProductionCubeData_TTL]',16,1);  
  EXEC [dbo].[P_LOG_ERROR] N'Error raised in [dbo].[P_UPDATE_FCT_CFO]'
                          ,N'[dbo].[P_UPDATE_FCT_CFO]' ;
  --SELECT * FROM [dbo].[LOG_ERROR]
END CATCH; 
SET NOCOUNT OFF;

END

