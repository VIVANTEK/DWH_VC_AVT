
CREATE PROCEDURE [dbo].[P_UPDATE_FCT_PROFIT_LOSS]         
AS
--====================================================================
--Created: 21-Jul-2022                           Altered: 26-Jul-2022       
--====================================================================
--This procedure is used in trigger for writeback-table [dbo].[WRB_PROFIT_LOSS]
--It transfer data from [dbo].[WRB_PROFIT_LOSS] to table [dbo].[FCT_PROFIT_LOSS]
--====================================================================
/*
 exec sp_recompile '[dbo].[pUpdateTable_FCT_PROFIT_LOSS]' 
 --------------------------------------------------------------------
 SELECT * FROM [dbo].[V_WRB_PROFIT_LOSS]
 SELECT * FROM [dbo].[FCT_PROFIT_LOSS]
 EXEC [dbo].[pUpdateTable_FCT_PROFIT_LOSS]  
 --------------------------------------------------------------------
 --TRUNCATE TABLE [dbo].[WRB_PROFIT_LOSS]
 --------------------------------------------------------------------
*/
--=====================================================================

BEGIN
SET NOCOUNT ON; 
BEGIN TRY 

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--Log updated data first
  INSERT INTO [dbo].[LOG_PROFIT_LOSS]
        ([PNL_ITEM],[FLIGHT],[MONTH_ID],[VERSION]--, [FLD_NAME]
		,[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER]) -- 
  SELECT SRC.[PNL_ITEM]
       , SRC.[FLIGHT]
       , SRC.[MONTH_ID]
       , SRC.[VERSION]
	 --, [FLD_NAME] = N'PNL_AMOUNT'
       , [OLD_VALUE] = DST.[PNL_AMOUNT]
       , [NEW_VALUE] = ISNULL(SRC.[PNL_AMOUNT],0.0) + ISNULL(DST.[PNL_AMOUNT],0.0)
       , SRC.[LOG_TIME] 
       , SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_PROFIT_LOSS]   AS SRC
  LEFT JOIN [dbo].[FCT_PROFIT_LOSS] AS DST
  ON  SRC.[PNL_ITEM] = DST.[PNL_ITEM]
  AND SRC.[FLIGHT]   = DST.[FLIGHT]
  AND SRC.[MONTH_ID] = DST.[MONTH_ID]
  AND SRC.[VERSION]  = DST.[VERSION]

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Synchronize the target table with refreshed data from source table
  MERGE [dbo].[FCT_PROFIT_LOSS]   AS TRG
  USING [dbo].[V_WRB_PROFIT_LOSS]  AS SRC 
  ON  TRG.[PNL_ITEM]  = SRC.[PNL_ITEM]
  AND TRG.[FLIGHT]    = SRC.[FLIGHT]
  AND TRG.[MONTH_ID]  = SRC.[MONTH_ID]
  AND TRG.[VERSION]   = SRC.[VERSION]
--AND TRG.[FLD_NAME]  = SRC.[FLD_NAME]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When records are matched, update the records if there is any change
  WHEN MATCHED  THEN UPDATE SET  
       TRG.[PNL_AMOUNT] =  ISNULL(TRG.[PNL_AMOUNT],0) +  ISNULL(SRC.[PNL_AMOUNT],0)   
    --,TRG.[LOG_TIME] = SRC.[LOG_TIME]
    --,TRG.[LOG_USER] = SRC.[LOG_USER]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When no records are matched, insert the incoming records from SRC table to TRG table
--We insert all measure as NULL except [BDG_ACT_FLG] which is enterd by user
  WHEN NOT MATCHED BY TARGET THEN INSERT 
     ([PNL_ITEM]
     ,[FLIGHT]
     ,[MONTH_ID]
     ,[VERSION]
     ,[PNL_AMOUNT]
   --,[LOG_TIME]
   --,[LOG_USER]
   --,[LOAD_DATE]
     )  
  VALUES 
     (SRC.[PNL_ITEM]
     ,SRC.[FLIGHT]
     ,SRC.[MONTH_ID]
     ,SRC.[VERSION]
     ,SRC.[PNL_AMOUNT]
   --,SRC.[LOG_TIME]
   --,SRC.[LOG_USER]
   --,SRC.[LOAD_DATE]
	 ) ;

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When there is a row that exists in TRG and same record does not exist in SRC then delete this record from TRG
--WHEN NOT MATCHED BY SOURCE  THEN DELETE ;
   /*=========================================================================================
  --$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns 
  --one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row
	OUTPUT $action 
    ,DELETED.[PNL_ITEM]      AS [DEL_PNL_ITEM]
    ,DELETED.[FLIGHT]        AS [DEL_FLIGHT] 
    ,DELETED.[MONTH_ID]      AS [DEL_MONTH_ID]
    ,DELETED.[VERSION]       AS [DEL_VERSION]
	,DELETED.[PNL_AMOUNT]    AS [DEL_PNL_AMOUNT]
	--------------------------------------------------------------
    ,INSERTED.[PNL_ITEM]     AS [INS_PNL_ITEM]
    ,INSERTED.[FLIGHT]       AS [INS_FLIGHT] 
    ,INSERTED.[MONTH_ID]     AS [INS_MONTH_ID]
    ,INSERTED.[VERSION]      AS [INS_VERSION]
	,INSERTED.[PNL_AMOUNT]   AS [INS_PNL_AMOUNT]
   =========================================================================================*/
 --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
  TRUNCATE TABLE [dbo].[WRB_PROFIT_LOSS];
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Delete rows with zero-values from destination table once again in case user just zeroes data
--Otherwise EXCEPT-INSERT-command rnturns no rows. Also this makes table smaller
--DELETE FROM [dbo].[WRB_PROFIT_LOSS] WHERE ISNULL([PNL_AMOUNT],0) = 0 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
END TRY 
BEGIN CATCH 
  --RAISERROR ('Error raised in [dbo].[pUpdateProductionCubeData_TTL]',16,1);  
  EXEC [dbo].[P_LOG_ERROR] N'Error raised in [dbo].[P_UPDATE_FCT_PROFIT_LOSS]'
                          ,N'[dbo].[P_UPDATE_FCT_PROFIT_LOSS]' ;
  --SELECT * FROM [dbo].[LOG_ERROR]
END CATCH; 
SET NOCOUNT OFF;

END

