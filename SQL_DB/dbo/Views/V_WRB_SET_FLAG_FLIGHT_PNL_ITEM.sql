


CREATE VIEW [dbo].[V_WRB_SET_FLAG_FLIGHT_PNL_ITEM]
AS
--====================================================================
--Created: 20-Aug-2022                           Altered: 20-Aug-2022         
--====================================================================
--This view shows transformed data from Cube's WriteBack partion table
/*
----=============================================================
 SELECT * FROM [dbo].[V_WRB_SET_FLAG_FLIGHT_PNL_ITEM]
-----------------------------------------------
 SELECT * FROM [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
-----------------------------------------------
--truncate table [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
--===============================================================
*/
WITH WB AS
(SELECT [FLAG_FLIGHT_PNL_ITEM] = ISNULL([FLAG_FLIGHT_PNL_ITEM_0],0) 
       ,[PNL_ITEM]             = ISNULL([ITEM_1],N'')
       ,[FLIGHT]               = ISNULL([FLT_DESC_2],N'')
       ,[LOG_TIME]             = CAST([MS_AUDIT_TIME_3] as smalldatetime)
       ,[LOG_DATE]             = CAST([MS_AUDIT_TIME_3] as date)
       ,[LOG_USER]             = ISNULL([MS_AUDIT_USER_4],N'')
FROM  [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
)-- select * from WB

SELECT [PNL_ITEM],
       [FLIGHT]
      ,[FLAG_FLIGHT_PNL_ITEM] = SUM([FLAG_FLIGHT_PNL_ITEM])
      ,[LOG_TIME]             = MAX([LOG_TIME])
      ,[LOG_DATE]
	  ,[LOG_USER]   
	  ,[LOAD_DATE]              = CAST(GetDate() AS DATE)
FROM  WB
GROUP BY [PNL_ITEM],
         [FLIGHT],
		 [LOG_DATE],
		 [LOG_USER] 
--,[FLAG_FLIGHT_PNL_ITEM]  


