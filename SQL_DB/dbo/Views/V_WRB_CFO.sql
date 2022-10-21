
CREATE VIEW [dbo].[V_WRB_CFO]
AS
--====================================================================
--Created: 20-Aug-2022                           Altered: 20-Aug-2022         
--====================================================================
--This view shows transformed data from Cube's WriteBack partion table
/*
----=============================================================
 SELECT * FROM [dbo].[V_WRB_CFO]
-----------------------------------------------
 SELECT * FROM [dbo].[WRB_CFO]
-----------------------------------------------
--truncate table [dbo].[WRB_CFO]
--===============================================================
*/
WITH WB AS
(SELECT [PNL_AMOUNT] = ISNULL([CFO_AMOUNT_0],0)
       ,[VERSION]    = ISNULL([VERSION_1],N'')
       ,[MONTH_ID]   = ISNULL([MONTH_ID_2],0)
       ,[PNL_ITEM]   = ISNULL([ITEM_3],N'')
       ,[LAYER_ID]   = ISNULL([LAYER_ID_4],0)
       ,[CFO_NAME]   = ISNULL([CFO_NAME_5],N'')
       ,[LOG_TIME]   = CAST([MS_AUDIT_TIME_6] as smalldatetime)
       ,[LOG_DATE]   = CAST([MS_AUDIT_TIME_6] as date)
       ,[LOG_USER]   = ISNULL([MS_AUDIT_USER_7],N'')
FROM  [dbo].[WRB_CFO]
)-- select * from WB

SELECT [PNL_ITEM],[CFO_NAME],[MONTH_ID],[VERSION],[LAYER_ID]
      ,[PNL_AMOUNT] = SUM([PNL_AMOUNT])
      ,[LOG_TIME]   = MAX([LOG_TIME])
      ,[LOG_DATE],[LOG_USER]   
	  ,[LOAD_DATE] = CAST(GetDate() AS DATE)
FROM  WB
GROUP BY[PNL_ITEM],[CFO_NAME],[MONTH_ID],[VERSION],[LAYER_ID],[LOG_DATE],[LOG_USER]   



