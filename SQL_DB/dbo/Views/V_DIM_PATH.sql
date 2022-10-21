




-- select * from [dbo].[V_DIM_PATH]     --= 09 sec
CREATE VIEW [dbo].[V_DIM_PATH] 
AS 

WITH SCHEDULE as
(select  
 AIRLINE   = AIRLINE_DESIGNATOR 
,FLT      =  FLIGHT_NUMBER
,ORG      =  DEPARTURE_STATION
,DST      =  ARRIVAL_STATION
,FLIGHT_DATE
,DEP_TIME = cast(FLIGHT_DATE as datetime ) + cast ( AIRCRAFT_STD as datetime ) 
,ARR_TIME = cast(FLIGHT_DATE as datetime ) + cast ( AIRCRAFT_STA as datetime )
,AIRCRAFT_TYPE
,ORG_COUNTRY   = O.[COUNTRY_CODE]
,DST_COUNTRY   = D.[COUNTRY_CODE]
,ORG_REGION    = O.[REGION_CODE]                                                     
,DST_REGION    = D.[REGION_CODE]                                                     
from [sim].[DAT_DD_SCH]
LEFT JOIN [dbo].[DIM_AIRPORT] O on DEPARTURE_STATION = O.[AIRPORT_CODE]
LEFT JOIN [dbo].[DIM_AIRPORT] D on ARRIVAL_STATION   = D.[AIRPORT_CODE]
)

,SCHEDULE_LIST as 
(SELECT  
		 AIRLINE    
		,FLT      
		,ORG     
		,DST      
		,ORG_COUNTRY   
		,DST_COUNTRY   
		,ORG_REGION                                                        
		,DST_REGION  
		 from SCHEDULE
 GROUP BY 
		 AIRLINE    
		,FLT      
		,ORG     
		,DST      
		,ORG_COUNTRY   
		,DST_COUNTRY   
		,ORG_REGION                                                        
		,DST_REGION    
)

------------------------------------------------------------

SELECT  
 PATH_KEY       = SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST + '-' + SEG2.AIRLINE + SEG2.FLT  + '-' + SEG2.DST   
,FLT_PATH_ORG   = SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST 
,FLT_PATH_DST   = SEG1.DST + '-' + SEG2.AIRLINE + SEG2.FLT  + '-' + SEG2.DST  

,ORG_DST          = SEG1.ORG + '-' + SEG2.DST   
,ORG_DST_TYPE     = 'TRANSIT'                  
,ORG_AIRPORT      = SEG1.ORG                     
,VIA_AIRPORT      = SEG1.DST                     
,DST_AIRPORT      = SEG2.DST                     
-----------------------------------------------
--,ORG_FLT_KEY      = SEG1.AIRLINE+SEG1.FLT       
--,ORG_AIRLINE      = SEG1.AIRLINE                 
--,ORG_FLT          = SEG1.FLT                     
-----------------------------------------------
--,DST_FLT_KEY      = SEG2.AIRLINE+SEG2.FLT       
--,DST_AIRLINE      = SEG2.AIRLINE                 
--,DST_FLT          = SEG2.FLT                   
-----------------------------------------------
--,ORG_COUNTRY   = SEG1.ORG_COUNTRY             
--,DST_COUNTRY   = SEG2.DST_COUNTRY             
--,ORG_REGION    = SEG1.ORG_REGION              
--,DST_REGION    = SEG2.DST_REGION 
--  ,COEF_LOGIC = 0              
,COEF_LOGIC = CAST( ROUND(  [dbo].[FS_GET_DISTANCE_BEETWEEN_AIRPORTS](SEG1.ORG ,SEG2.DST , 'km' ) 
            / 
              NULLIF( ( [dbo].[FS_GET_DISTANCE_BEETWEEN_AIRPORTS](SEG1.ORG ,SEG1.DST , 'km' )  
					   + [dbo].[FS_GET_DISTANCE_BEETWEEN_AIRPORTS](SEG2.ORG ,SEG2.DST , 'km' ) 
					  ),0 --NULLIF() : если сумма выше = 0 или NULL верни NULL а не ошибку деления на 0
			        ) ,2 ) as decimal ( 3,2 ))
FROM SCHEDULE_LIST SEG1
JOIN  SCHEDULE_LIST SEG2  on SEG1.DST = SEG2.ORG  and SEG1.ORG <>  SEG2.DST  
WHERE SEG1.DST_COUNTRY = 'UA'

UNION ALL

SELECT  
SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST   as DIM_PATH ,
SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST   as FLT_PATH_ORG ,
SEG1.ORG + '-' + SEG1.AIRLINE + SEG1.FLT  + '-' + SEG1.DST   as FLT_PATH_DST ,

SEG1.ORG + '-' + SEG1.DST as  ORG_DST ,
'PTP'                     as  ORG_DST_TYPE ,
SEG1.ORG                  as  ORG_AIRPORT ,
NULL                      as  VIA_AIRPORT ,
SEG1.DST                  as  DST_AIRPORT ,
-----------------------------------------------
--SEG1.AIRLINE+SEG1.FLT     as  ORG_FLT_KEY ,
--SEG1.AIRLINE              as  ORG_AIRLINE ,
--SEG1.FLT                  as  ORG_FLT ,
-----------------------------------------------
--SEG1.AIRLINE+SEG1.FLT     as  DST_FLT_KEY ,
--SEG1.AIRLINE              as  DST_AIRLINE ,
--SEG1.FLT                  as  DST_FLT ,
-----------------------------------------------
--SEG1.ORG_COUNTRY          as  ORG_COUNTRY ,
--SEG1.DST_COUNTRY          as  DST_COUNTRY ,
--SEG1.ORG_REGION           as  ORG_REGION ,
--SEG1.DST_REGION           as  DST_REGION ,
1                           as  COEF_LOGIC  
FROM SCHEDULE_LIST SEG1








