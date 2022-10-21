


CREATE VIEW [dbo].[V_WRB_SET_FLEET]
AS
--====================================================================
--Created: 16-Aug-2022                           Altered: 22-Aug-2022       
--====================================================================
--This view shows transformed data from Cube's WriteBack partion table
/*
----=============================================================
 SELECT * FROM [dbo].[V_WRB_SET_FLEET]
-----------------------------------------------
 SELECT * FROM [dbo].[WRB_SET_FLEET]
-----------------------------------------------
--truncate table [dbo].[WRB_SET_FLEET]
--===============================================================
*/
WITH WB AS
(SELECT [CONSUMPTION_CHARTER]       = ISNULL([CONSUMPTION_CHARTER_0],0)
       ,[CONSUMPTION_DOMESTIC]      = ISNULL([CONSUMPTION_DOMESTIC_1],0)
       ,[CONSUMPTION_INTERNATIONAL] = ISNULL([CONSUMPTION_INTERNATIONAL_2],0)
       ,[WEIGHT_CAPACITY]           = ISNULL([WEIGHT_CAPACITY_3],0)
       ,[MTOW]                      = ISNULL([MTOW_4],0)
       ,[MONTH_ID]                  = [MONTH_ID_5]
       ,[TRANSPORT_CODE]            = [TRANSPORT_CODE_6]

       ,[LOG_TIME]                  = CAST([MS_AUDIT_TIME_7] as smalldatetime)
       ,[LOG_DATE]                  = CAST([MS_AUDIT_TIME_7] as date)
       ,[LOG_USER]                  = [MS_AUDIT_USER_8]
FROM  [dbo].[WRB_SET_FLEET]
)-- select * from WB


SELECT [TRANSPORT_CODE] 
      ,[MONTH_ID]  
      ,[CONSUMPTION_CHARTER]      = SUM([CONSUMPTION_CHARTER])
      ,[CONSUMPTION_DOMESTIC]     = SUM([CONSUMPTION_DOMESTIC])
      ,[CONSUMPTION_INTERNATIONAL]= SUM([CONSUMPTION_INTERNATIONAL])  
      ,[WEIGHT_CAPACITY]          = SUM([WEIGHT_CAPACITY])
      ,[MTOW]                     = SUM([MTOW])
      ,[LOG_TIME]   = MAX([LOG_TIME])
      ,[LOG_DATE]    
      ,[LOG_USER]   
	  ,[LOAD_DATE] = CAST(GetDate() AS DATE)
FROM  WB
GROUP BY [TRANSPORT_CODE],[MONTH_ID],[LOG_DATE],[LOG_USER]   



