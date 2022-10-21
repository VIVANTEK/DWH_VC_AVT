﻿

--select COUNT(*) from [dbo].[V_FCT_SCHEDULE_FLIGHT_TRANSIT] where ISNULL(COUNT_CONNECTION,0) = 0
--select COUNT(*) from  [dbo].[PBL_SCHEDULE_TRANSIT]  WHERE ISNULL([COUNT_CONNECTION],0) = 0
--DELETE FROM  [dbo].[PBL_SCHEDULE_TRANSIT]  WHERE ISNULL([COUNT_CONNECTION],0) = 0 ;

CREATE VIEW [dbo].[V_FCT_SCHEDULE_FLIGHT_TRANSIT] as 

WITH SCHEDULE as
(select  DISTINCT
 AIRLINE   = AIRLINE_DESIGNATOR 
,FLT      =  FLIGHT_NUMBER
,ORG      =  DEPARTURE_STATION
,DST      =  ARRIVAL_STATION
,FLT_DESC        = [DEPARTURE_STATION] + '-' + [AIRLINE_DESIGNATOR]    + [FLIGHT_NUMBER]        + '-' + [ARRIVAL_STATION]
,FLT_DESC_OP     = [DEPARTURE_STATION] + '-' + [AIRLINE_DESIGNATOR_OP] + [FLIGHT_NUMBER_OP]     + '-' + [ARRIVAL_STATION] 
,FLIGHT_DATE     = CAST ( [DEPARTURE_DATE] AS DATE )
,DEP_TIME        = [DEPARTURE_DATE]  
,ARR_TIME        = [ARRIVAL_DATE]
,ORG_COUNTRY   = O.[COUNTRY_CODE]
,DST_COUNTRY   = D.[COUNTRY_CODE]
,ORG_REGION    = O.[REGION_CODE]                                                     
,DST_REGION    = D.[REGION_CODE]                                                     
 FROM [sim].[DAT_DD_SCH_CAP]
LEFT JOIN [dbo].[DIM_AIRPORT] O on DEPARTURE_STATION = O.[AIRPORT_CODE]
LEFT JOIN [dbo].[DIM_AIRPORT] D on ARRIVAL_STATION   = D.[AIRPORT_CODE]
)



SELECT    AGG.[PATH_KEY] 
	     ,AGG.FLIGHT_DATE 
	  -- ,[DIM_TIME_RANGE_CONNECTION] = AGG.DIM_TIME_RANGE_CONNECTION 
	     ,[RNG_ID]                    = ISNULL(RNG.[RNG_ID], 0)
		 ,[VERSION] = 'FCST'
      -- ,AGG.ARR_HUB_TIME_MI  
	  -- ,AGG.DEP_HUB_TIME_MI 
	  -- ,AGG.OVER_NIGHT 
	     ,AGG.COUNT_CONNECTION
	  -- ,COUNT_ORG      = NULL
	  -- ,COUNT_DST      = NULL	
     --  ,DIM_TIME_HUB = ISNULL(RNG_HUB.[TIMERANGE], 'ArrOrg (XX:XX - XX:XX ) - DepDst (XX:XX - XX:XX)')  
	 --  ,AGG.DATE_LOAD
FROM
(SELECT 
       AIRPORT_CONNECTION         = SEG1.DST  
       ,[PATH_KEY]                  = SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST + '-' +SEG2.AIRLINE + SEG2.FLT  + '-' + SEG2.DST   
       ,FLIGHT_DATE               =  SEG1.FLIGHT_DATE 
       ,DIM_TIME_RANGE_CONNECTION =  DATEDIFF ( MI , SEG1.[ARR_TIME] , SEG2.[DEP_TIME] )                                            
	-- , ARR_HUB_TIME_MI =  DATEPART ( HH , SEG1.[ARR_TIME] ) * 60 +   DATEPART ( MI , SEG1.[ARR_TIME] )              
	-- , DEP_HUB_TIME_MI =  DATEPART ( HH , SEG2.[DEP_TIME] ) * 60  +  DATEPART ( MI , SEG2.[DEP_TIME] )     
	-- , OVER_NIGHT = CASE WHEN  DATEPART ( HH , SEG1.[DEP_TIME] ) * 60  +  DATEPART ( MI , SEG1.[DEP_TIME] ) <
	  --            DATEPART ( HH , SEG2.[DEP_TIME] ) * 60  +  DATEPART ( MI , SEG2.[DEP_TIME] )
			--THEN 0 ELSE 1 END  
      ,COUNT_CONNECTION =  1 
	 --  DATE_LOAD = CAST(GetDate() as date)
FROM SCHEDULE AS SEG1  WITH (NOLOCK) 
JOIN SCHEDULE AS SEG2  WITH (NOLOCK) 
ON SEG1.DST = SEG2.ORG  
  AND SEG1.ORG != SEG2.DST 
  AND SEG1.[ARR_TIME]  <=  SEG2.[DEP_TIME] 
  AND DATEDIFF ( MI, SEG1.[ARR_TIME] , SEG2.[DEP_TIME] ) BETWEEN 0 AND 1439
WHERE SEG1.DST_COUNTRY = 'UA'
) AS AGG
LEFT OUTER JOIN [DWH_VC_AVT].[dbo].[V_DIM_TIME_RANGE] AS RNG WITH (NOLOCK) ON AGG.DIM_TIME_RANGE_CONNECTION BETWEEN RNG.[PERIOD_B] AND RNG.[PERIOD_E]  AND RNG.RNG_ID <> 0 
--LEFT OUTER JOIN V_D_TimeRangeHub AS RNG_HUB WITH (NOLOCK) ON   AGG.ARR_HUB_TIME_MI  BETWEEN [ARR_HUB_PERIOD_B] AND [ARR_HUB_PERIOD_E] AND
--       AGG.DEP_HUB_TIME_MI  BETWEEN [DEP_HUB_PERIOD_B] AND [DEP_HUB_PERIOD_E] AND
--	   AIRPORT_CONNECTION = 'KBP'

--UNION ALL

--SELECT SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST   as DIM_PATH, 
--	   CAST (SEG1.DEP_TIME as date) as DIM_DATE, 
--	   0                            as DIM_TIME_RANGE_CONNECTION, 
--	   case when  SEG1.DST = 'KBP' then  DATEPART ( HH , SEG1.[ARR_TIME] ) * 60 +   DATEPART ( MI , SEG1.[ARR_TIME] )   else 0 end as ARR_HUB_TIME_MI ,
--	   case when  SEG1.ORG = 'KBP' then  DATEPART ( HH , SEG1.[DEP_TIME] ) * 60  +  DATEPART ( MI , SEG1.[DEP_TIME] )   else 0 end as DEP_HUB_TIME_MI ,
--	   OVER_NIGHT = 0 , 
--	   COUNT_CONNECTION = NULL,  
--	   COUNT_ORG  = NULL, 
--	   COUNT_DST = NULL,
--	   RngID = 0, 
--   --    'ArrOrg (XX:XX - XX:XX ) - DepDst (XX:XX - XX:XX)' as DIM_TIME_HUB, 
--	    DATE_LOAD = CAST(GetDate() as date) 

--FROM SCHEDULE AS SEG1  WITH (NOLOCK) 


