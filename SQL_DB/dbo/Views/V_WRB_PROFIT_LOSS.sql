






CREATE VIEW [dbo].[V_WRB_PROFIT_LOSS]
AS
--====================================================================
--Created: 21-Jul-2022                           Altered: 22-Aug-2022       
--====================================================================
--This view shows transformed data from Cube's WriteBack partion table
/*
----=============================================================
 SELECT * FROM [dbo].[V_WRB_PROFIT_LOSS]
-----------------------------------------------
 SELECT * FROM [dbo].[WRB_PROFIT_LOSS]
-----------------------------------------------
--truncate table [dbo].[WRB_PROFIT_LOSS]
--===============================================================
*/
WITH WB AS
(SELECT [PNL_AMOUNT] = ISNULL([PNL_AMOUNT_0],0.0)
       ,[MONTH_ID]   = [MONTH_ID_1]
       ,[PNL_ITEM]   = [ITEM_2]
       ,[VERSION]    = [VERSION_3]
       ,[FLIGHT]     = [FLT_DESC_4]
       ,[LOG_TIME]   = CAST([MS_AUDIT_TIME_5] as smalldatetime)
       ,[LOG_DATE]   = CAST([MS_AUDIT_TIME_5] as date)
       ,[LOG_USER]   = [MS_AUDIT_USER_6]
 FROM [dbo].[WRB_PROFIT_LOSS]
)-- select * from WB

SELECT [PNL_ITEM] 
      ,[FLIGHT]    
      ,[MONTH_ID]
      ,[VERSION]
      ,[PNL_AMOUNT]  = SUM([PNL_AMOUNT])
      ,[LOG_TIME]    = MAX([LOG_TIME])
      ,[LOG_DATE]
      ,[LOG_USER]
	  ,[LOAD_DATE] = CAST(GetDate() AS DATE)
 FROM WB 
 GROUP BY [MONTH_ID],[PNL_ITEM],[FLIGHT],[VERSION],[LOG_DATE],[LOG_USER]









