﻿
-- select * from [sim].[V_REP_AGG_WK_VIEW]  
CREATE VIEW [sim].[V_REP_AGG_WK_VIEW]  
AS
 
 SELECT DISTINCT [AIRLINE_DESIGNATOR]  
	,[FLIGHT_NUMBER] 
	,[DEPARTURE_STATION] 
	,[ARRIVAL_STATION] 
	,[OPERATION_PERIOD_FROM]  
	,[OPERATION_PERIOD_TO] 
	,[OPERATION_WEEKDAY_LIST] = REPLACE([OPERATION_WEEKDAY_LIST], '0', '_')
	,[STD_LT] = [AIRCRAFT_STD]
	,[STA_LT] = [AIRCRAFT_STA]
	,[STD_UTC] = cast(DATEADD(minute, DateDiff(minute, cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STD] AS DATETIME), TODATETIMEOFFSET(cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STD] AS DATETIME), [TIME_VARIATION_DEPARTURE])), cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STD] AS DATETIME)) AS TIME)
	,[STA_UTC] = cast(DATEADD(minute, DateDiff(minute, cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STA] AS DATETIME), TODATETIMEOFFSET(cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STA] AS DATETIME), [TIME_VARIATION_ARRIVAL])), cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STA] AS DATETIME)) AS TIME)
FROM [sim].[DAT_DD_SCH]
WHERE [OPERATION_PERIOD_FROM] >= cast(getdate() AS DATE)
	AND [FLIGHT_DATE]         >= cast(getdate() AS DATE)
	AND [AIRLINE_DESIGNATOR]  = 'PS'
  --and [FLIGHT_NUMBER]  = '00101'


