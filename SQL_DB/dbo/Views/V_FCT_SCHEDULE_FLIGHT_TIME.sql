﻿CREATE VIEW [dbo].[V_FCT_SCHEDULE_FLIGHT_TIME]  AS 

WITH HUB_SET as ( select  HUB ='KBP' )

    ,SCHEDULE_MI_NUMBER as (
SELECT  DISTINCT 
	 FLT_DESC        = [DEPARTURE_STATION] + '-' + [AIRLINE_DESIGNATOR]    + [FLIGHT_NUMBER]        + '-' + [ARRIVAL_STATION]
	,FLT_DESC_OP     = [DEPARTURE_STATION] + '-' + [AIRLINE_DESIGNATOR_OP] + [FLIGHT_NUMBER_OP]     + '-' + [ARRIVAL_STATION] 
	,ORIG = [DEPARTURE_STATION]
	,DSTN = [ARRIVAL_STATION]
	,DEP_TIME        = [DEPARTURE_DATE]  
	,DEP_TIME_MI_NUMBER = datepart (HH , [DEPARTURE_DATE]) * 60  + datepart (MI , [DEPARTURE_DATE])
	,DEP_TIME_RNG_ID    =  DEP.RNG_ID 
	,ARR_TIME        = [ARRIVAL_DATE]
	,ARR_TIME_MI_NUMBER = datepart (HH , [ARRIVAL_DATE]) * 60  + datepart (MI , [ARRIVAL_DATE])
	,ARR_TIME_RNG_ID    =  ARR.RNG_ID 
	,VERSION = 'FCST'

FROM [sim].[DAT_DD_SCH_CAP]
LEFT JOIN [dbo].[V_DIM_TIME_RANGE] DEP ON  datepart (HH , [DEPARTURE_DATE]) * 60  + datepart (MI , [DEPARTURE_DATE]) between  DEP.PERIOD_B and DEP.PERIOD_E
LEFT JOIN [dbo].[V_DIM_TIME_RANGE] ARR ON  datepart (HH , [ARRIVAL_DATE]) * 60    + datepart (MI , [ARRIVAL_DATE])   between  ARR.PERIOD_B and ARR.PERIOD_E
)

select FLT_DESC ,
	   FLIGHT_DATE = CAST( DEP_TIME as  DATE ) ,
	   VERSION ,
	   RNG_ID = DEP_TIME_RNG_ID ,
	   FLIGHT_TIME_DEP =  1 ,
	   HUB_TIME_DEP    = CASE WHEN ORIG = HUB then 1 else null end ,
	   FLIGHT_TIME_ARR = NULL,
	   HUB_TIME_ARR = NULL 
 from SCHEDULE_MI_NUMBER
  JOIN HUB_SET ON 1=1

 UNION ALL 

 select FLT_DESC ,
	    FLIGHT_DATE = CAST( ARR_TIME as DATE ) ,
	    VERSION ,
	    RNG_ID =  ARR_TIME_RNG_ID ,
		FLIGHT_TIME_DEP = NULL ,
		HUB_TIME_DEP    = NULL ,
	    FLIGHT_TIME_ARR =  -1  ,  
		HUB_TIME_ARR    = CASE WHEN DSTN = HUB then -1 else null end 
 from SCHEDULE_MI_NUMBER
 JOIN HUB_SET ON 1=1