

CREATE PROCEDURE [dbo].[P_UPDATE_FCT_SET_FLAG_FLIGHT_PNL_ITEM]         
AS
--==========================================================================================
--Created: 20-Aug-2022                                                Altered: 20-Aug-2022         
--==========================================================================================
--This procedure is used in trigger for writeback-table [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
--It transfer data [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM] --> [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
--==========================================================================================
/*
 exec sp_recompile '[dbo].[P_UPDATE_FCT_SET_FLAG_FLIGHT_PNL_ITEM]' 
 --------------------------------------------------------------------
 SELECT * FROM [dbo].[V_WRB_SET_FLAG_FLIGHT_PNL_ITEM]
 SELECT * FROM [dbo].[FCT_SET_FLAG_FLIGHT_PNL_ITEM]
 EXEC [dbo].[P_UPDATE_FCT_SET_FLAG_FLIGHT_PNL_ITEM] 
 --------------------------------------------------------------------
 --TRUNCATE TABLE [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
 --select * from [dbo].[LOG_SET_FLAG_FLIGHT_PNL_ITEM] 
 --truncate table [dbo].[LOG_SET_FLAG_FLIGHT_PNL_ITEM]
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
  INSERT INTO [dbo].[LOG_SET_FLAG_FLIGHT_PNL_ITEM]
        ([PNL_ITEM],[FLIGHT],[OLD_VALUE],[NEW_VALUE],[LOG_TIME],[LOG_USER] ) -- ,[FLD_NAME]) -- = [FLAG_FLIGHT_PNL_ITEM]
  SELECT SRC.[PNL_ITEM],SRC.[FLIGHT] 
       , [OLD_VALUE] = ISNULL(DST.[FLAG_FLIGHT_PNL_ITEM],0)
       , [NEW_VALUE] = ISNULL(SRC.[FLAG_FLIGHT_PNL_ITEM],0) + ISNULL(DST.[FLAG_FLIGHT_PNL_ITEM],0)
       , SRC.[LOG_TIME],SRC.[LOG_USER]
  FROM  [dbo].[V_WRB_SET_FLAG_FLIGHT_PNL_ITEM] AS SRC
  LEFT JOIN [dbo].[FCT_SET_FLAG_FLIGHT_PNL_ITEM] AS DST 
  ON  SRC.[PNL_ITEM] = DST.[PNL_ITEM]
  AND SRC.[FLIGHT]   = DST.[FLIGHT]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MERGE DATA @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Synchronize the target table with refreshed data from source table
  MERGE [dbo].[FCT_SET_FLAG_FLIGHT_PNL_ITEM]   AS TRG  
  USING [dbo].[V_WRB_SET_FLAG_FLIGHT_PNL_ITEM] AS SRC 
  ON  TRG.[PNL_ITEM] = SRC.[PNL_ITEM]
  AND TRG.[FLIGHT]   = SRC.[FLIGHT]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When records are matched, update the records if there is any change
  WHEN MATCHED  THEN UPDATE SET  
       TRG.[FLAG_FLIGHT_PNL_ITEM] = ISNULL(TRG.[FLAG_FLIGHT_PNL_ITEM],0) + ISNULL(SRC.[FLAG_FLIGHT_PNL_ITEM],0)   
    --,TRG.[LOG_USER] = SRC.[LOG_USER]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When no records are matched, insert the incoming records from SRC table to TRG table
--We insert all measure as NULL except [BDG_ACT_FLG] which is enterd by user
  WHEN NOT MATCHED BY TARGET THEN INSERT  
         ([PNL_ITEM],        [FLIGHT],    [FLAG_FLIGHT_PNL_ITEM])     
  VALUES (SRC.[PNL_ITEM],SRC.[FLIGHT],SRC.[FLAG_FLIGHT_PNL_ITEM]) ;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--When there is a row that exists in TRG and same record does not exist in SRC then delete this record from TRG
--WHEN NOT MATCHED BY SOURCE  THEN DELETE ;
   /*=========================================================================================
  --$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns 
  --one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row
	OUTPUT $action 
    ,DELETED.[PNL_ITEM]                 AS [DEL_PNL_ITEM]
    ,DELETED.[FLIGHT]                   AS [DEL_FLIGHT]
    ,DELETED.[FLAG_FLIGHT_PNL_ITEM]     AS [DEL_FLAG_FLIGHT_PNL_ITEM] 
	--------------------------------------------------------------
    ,INSERTED.[PNL_ITEM]                AS [INS_PNL_ITEM]
    ,INSERTED.[CFO_NAMER]               AS [INS_FLIGHT]
    ,INSERTED.[FLAG_FLIGHT_PNL_ITEM]    AS [INS_FLAG_FLIGHT_PNL_ITEM] 
   =========================================================================================*/
 --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
  TRUNCATE TABLE [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM];
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Delete rows with zero-values from destination table once again in case user just zeroes data
--Otherwise EXCEPT-INSERT-command rnturns no rows. Also this makes table smaller
--DELETE FROM [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM] WHERE ISNULL([FLAG_FLIGHT_PNL_ITEM],0) = 0 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
END TRY 
BEGIN CATCH 
  --RAISERROR ('Error raised in [dbo].[pUpdateProductionCubeData_TTL]',16,1);  
  EXEC [dbo].[P_LOG_ERROR] N'Error raised in [dbo].[P_UPDATE_FCT_SET_FLAG_FLIGHT_PNL_ITEM]'
                          ,N'[dbo].[P_UPDATE_FCT_SET_FLAG_FLIGHT_PNL_ITEM]' ;
  --SELECT * FROM [dbo].[LOG_ERROR]
END CATCH; 
SET NOCOUNT OFF;

END
