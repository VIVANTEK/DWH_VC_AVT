﻿CREATE FUNCTION  [sim].[FT_TMP_PRS_S2]
(@FILE_NAME varchar(255) = NULL)  --Mon,Tue,...,Sun
--==================================================================================================
--Created: 20-Jun-2022                                                       Altered: 20-Jun-2022  
--==================================================================================================
--Returns processed Schedule data drom imported SSIM-file
/*
--Usage example:
SELECT * FROM [sim].[ft_TMP_PRS_S2]('SSIM7PS0001_9999_1047951')  
--WHERE ( CAST([FLIGHT_NUMBER] as int)   = 23 and FLIGHT_DATE = '2022-10-30' )
ORDER BY [FLIGHT_NUMBER],[OPERATION_PERIOD_FROM], [FLIGHT_DATE]
OPTION (MAXRECURSION 3660);
*/
--==================================================================================================
RETURNS TABLE 
AS
RETURN 
(-- DECLARE @FILE_NAME varchar(255) = 'SSIM7PS0001_9999_1041025';
WITH CTE AS 
(SELECT * 
      ,FLIGHT_UNIQUE_KEY = [FLIGHT_NUMBER] + '|' 
	                     + [AIRLINE_DESIGNATOR] + '|' 
					     + FORMAT(ISNULL([FLIGHT_DATE],'1901-01-01') ,'yyyy-MM-dd')
FROM [sim].[TMP_PRS_S2] --[dbo].[TMP_SSIM] 
WHERE ( [FILE_NAME] = @FILE_NAME OR  @FILE_NAME IS NULL)
) 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
,FlightTypes AS
(SELECT [AIRLINE_DESIGNATOR],[FLIGHT_NUMBER],[FLIGHT_DATE],[FLIGHT_UNIQUE_KEY]
	   ,[LEG_SEQUENCE_NUMBER] = MAX([LEG_SEQUENCE_NUMBER])
	   ,[RC] = COUNT(*)
	  , [ROW_TYPE] = CASE 
	                 WHEN COUNT(*) = 1 AND MAX([LEG_SEQUENCE_NUMBER]) = '01' THEN  1 -- single row (standard)
					 WHEN COUNT(*) = 1 AND MAX([LEG_SEQUENCE_NUMBER]) = '02' THEN -1 -- single row (flight overlaps 2 dates)
					 WHEN COUNT(*) = 2 AND MAX([LEG_SEQUENCE_NUMBER]) = '02' THEN  2 -- doble row (flight has 2 legs in one day)
	                 ELSE 0 -- undefined situation
				  END
 FROM CTE GROUP BY [FLIGHT_NUMBER],[AIRLINE_DESIGNATOR], [FLIGHT_DATE],[FLIGHT_UNIQUE_KEY]
 ) -- select * from FlightTypes where [ROW_TYPE] = -1
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
,RESULT AS
(SELECT --********************** Flight with Single Leg row type (standard rows, no additional processing) *********************** 
 [RECORD_TYPE]
,[AIRLINE_DESIGNATOR]
,[FLIGHT_NUMBER]
,[AIRLINE_DESIGNATOR_OP]
,[FLIGHT_NUMBER_OP]
,[ITINERARY_VARIATION_IDENTIFIER]
,[LEG_SEQUENCE_NUMBER]
,[SERVICE_TYPE]
,[OPERATION_PERIOD_FROM]
,[OPERATION_PERIOD_TO]
,[FLIGHT_DATE]
,[FLIGHT_DOW_NAME]
,[FLIGHT_DOW_NUM]
,[OPERATION_WEEKDAY_LIST]
,[FREQUENCY_RATE]
,[DEPARTURE_STATION]
,[PASSENGER_STD]
,[AIRCRAFT_STD]
,[TIME_VARIATION_DEPARTURE]
,[ARRIVAL_STATION]
,[AIRCRAFT_STA]
,[PASSENGER_STA]
,[TIME_VARIATION_ARRIVAL]
,[AIRCRAFT_TYPE]
,[AIRCRAFT_CONFIGURATION_VERSION]
,[OPERATIONAL_SUFFIX]
,[PASSENGER_TERMINAL_DEPARTURE]
,[PASSENGER_TERMINAL_ARRIVAL]
,[PRBD]
,[PRBM]
,[MEAL_SERVICE_NOTE]
,[JOINT_OPERATIONAL_AIRLINE_DESIGNATOR]
,[LEG_DEPARTURE_STATUS]
,[INTERNATIONAL_DOMESTIC_STATUS]
,[ITINERARY_VARIATION_IDENTIFIER_OVERFLOW]
,[AIRCRAFT_OWNER]
,[COCKPIT_CREW_EMPLOYER]
,[CABIN_CREW_EMPLOYER]
,[AIRLINE_DESIGNATOR_ONWARD]
,[FLIGHT_NUMBER_ONWARD]
,[AIRCRAFT_ROTATION_LAYOVER_ONWARD]
,[OPERATIONAL_SUFFIX_ONWARD]
,[FLIGHT_TRANSIT_LAYOVER]
,[CODE_SHARING]
,[TRAFFIC_RESTRICTION_CODE]
,[LEG_OVERFLOW_INDICATOR]
,[BILATERAL_INFORMATION]
,[RECORD_SERIAL_NUMBER]
,[ROW_TYPE] = 1
,[ACTIVE],[FILE_NAME],[LOAD_DATE] 
FROM CTE WHERE  FLIGHT_UNIQUE_KEY IN (select distinct FLIGHT_UNIQUE_KEY from FlightTypes where [ROW_TYPE] = 1)
    
	UNION

SELECT --********************** Flight with Double Leg row type (should have special processing) *********************************
 [RECORD_TYPE]
,[AIRLINE_DESIGNATOR]
,[FLIGHT_NUMBER]
,[AIRLINE_DESIGNATOR_OP]
,[FLIGHT_NUMBER_OP]
,[ITINERARY_VARIATION_IDENTIFIER]
,[LEG_SEQUENCE_NUMBER] = MAX([LEG_SEQUENCE_NUMBER])
,[SERVICE_TYPE]
,[OPERATION_PERIOD_FROM]
,[OPERATION_PERIOD_TO]
,[FLIGHT_DATE]
,[FLIGHT_DOW_NAME]
,[FLIGHT_DOW_NUM]
,[OPERATION_WEEKDAY_LIST]
,[FREQUENCY_RATE]
,[DEPARTURE_STATION]        = MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [DEPARTURE_STATION] else null end)
,[PASSENGER_STD]            = MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [PASSENGER_STD] else null end )
,[AIRCRAFT_STD]             = MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [AIRCRAFT_STD] else null end )
,[TIME_VARIATION_DEPARTURE]  = MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [TIME_VARIATION_DEPARTURE] else null end)
,[ARRIVAL_STATION]          = MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [ARRIVAL_STATION] else null end )
,[AIRCRAFT_STA]             = MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [AIRCRAFT_STA] else null end)
,[PASSENGER_STA]            = MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [PASSENGER_STA] else null end)
,[TIME_VARIATION_ARRIVAL]    = MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [TIME_VARIATION_ARRIVAL] else null end)
,[AIRCRAFT_TYPE]
,[AIRCRAFT_CONFIGURATION_VERSION]
,[OPERATIONAL_SUFFIX]
,[PASSENGER_TERMINAL_DEPARTURE]  = MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [PASSENGER_TERMINAL_DEPARTURE] else null end )
,[PASSENGER_TERMINAL_ARRIVAL]    = MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [PASSENGER_TERMINAL_ARRIVAL] else null end )
,[PRBD]
,[PRBM]
,[MEAL_SERVICE_NOTE]
,[JOINT_OPERATIONAL_AIRLINE_DESIGNATOR]
,[LEG_DEPARTURE_STATUS]
,[INTERNATIONAL_DOMESTIC_STATUS]
,[ITINERARY_VARIATION_IDENTIFIER_OVERFLOW]
,[AIRCRAFT_OWNER]
,[COCKPIT_CREW_EMPLOYER]
,[CABIN_CREW_EMPLOYER]
,[AIRLINE_DESIGNATOR_ONWARD]
,[FLIGHT_NUMBER_ONWARD]
,[AIRCRAFT_ROTATION_LAYOVER_ONWARD]
,[OPERATIONAL_SUFFIX_ONWARD]
,[FLIGHT_TRANSIT_LAYOVER]
,[CODE_SHARING]
,[TRAFFIC_RESTRICTION_CODE] = MAX( [TRAFFIC_RESTRICTION_CODE] )
,[LEG_OVERFLOW_INDICATOR]
,[BILATERAL_INFORMATION]
,[RECORD_SERIAL_NUMBER] = MAX( [RECORD_SERIAL_NUMBER] )
,[ROW_TYPE] = 2
,[ACTIVE],[FILE_NAME],[LOAD_DATE] 
FROM CTE WHERE  FLIGHT_UNIQUE_KEY IN (select distinct FLIGHT_UNIQUE_KEY from FlightTypes where [ROW_TYPE] = 2)
GROUP BY [LOAD_DATE],[FILE_NAME],[ACTIVE],[RECORD_TYPE],[AIRLINE_DESIGNATOR],[FLIGHT_NUMBER],[AIRLINE_DESIGNATOR_OP]
,[FLIGHT_NUMBER_OP],[ITINERARY_VARIATION_IDENTIFIER],[SERVICE_TYPE],[OPERATION_PERIOD_FROM],[OPERATION_PERIOD_TO]
,[FLIGHT_DATE],[FLIGHT_DOW_NAME],[FLIGHT_DOW_NUM],[OPERATION_WEEKDAY_LIST],[FREQUENCY_RATE],[AIRCRAFT_TYPE]
,[AIRCRAFT_CONFIGURATION_VERSION],[OPERATIONAL_SUFFIX],[PRBD],[PRBM],[MEAL_SERVICE_NOTE],[JOINT_OPERATIONAL_AIRLINE_DESIGNATOR]
,[LEG_DEPARTURE_STATUS],[INTERNATIONAL_DOMESTIC_STATUS],[ITINERARY_VARIATION_IDENTIFIER_OVERFLOW],[AIRCRAFT_OWNER]
,[COCKPIT_CREW_EMPLOYER],[CABIN_CREW_EMPLOYER],[AIRLINE_DESIGNATOR_ONWARD],[FLIGHT_NUMBER_ONWARD],[AIRCRAFT_ROTATION_LAYOVER_ONWARD]
,[OPERATIONAL_SUFFIX_ONWARD],[FLIGHT_TRANSIT_LAYOVER],[CODE_SHARING],[LEG_OVERFLOW_INDICATOR],[BILATERAL_INFORMATION]

	UNION

SELECT --********************** Flight with single Leg = 02 only (should have special processing) *********************************
 T2.[RECORD_TYPE]
,T2.[AIRLINE_DESIGNATOR]
,T2.[FLIGHT_NUMBER]
,T2.[AIRLINE_DESIGNATOR_OP]
,T2.[FLIGHT_NUMBER_OP]
,T2.[ITINERARY_VARIATION_IDENTIFIER]
,[LEG_SEQUENCE_NUMBER] = T2.[LEG_SEQUENCE_NUMBER]           --MAX([LEG_SEQUENCE_NUMBER])
,T2.[SERVICE_TYPE]
,T2.[OPERATION_PERIOD_FROM]
,T2.[OPERATION_PERIOD_TO]
,T2.[FLIGHT_DATE]
,T2.[FLIGHT_DOW_NAME]
,T2.[FLIGHT_DOW_NUM]
,T2.[OPERATION_WEEKDAY_LIST]
,T2.[FREQUENCY_RATE]
,[DEPARTURE_STATION]        = T1.[DEPARTURE_STATION]      --MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [DEPARTURE_STATION] else null end)
,[PASSENGER_STD]            = T1.[PASSENGER_STD]          --MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [PASSENGER_STD] else null end )
,[AIRCRAFT_STD]             = T1.[AIRCRAFT_STD]           --MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [AIRCRAFT_STD] else null end )
,[TIME_VARIATION_DEPARTURE]  = T1.[TIME_VARIATION_DEPARTURE]--MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [TIME_VARIATION_DEPARTURE] else null end)

,[ARRIVAL_STATION]          = T2.[ARRIVAL_STATION]        --MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [ARRIVAL_STATION] else null end )
,[AIRCRAFT_STA]             = T2.[AIRCRAFT_STA]           --MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [AIRCRAFT_STA] else null end)
,[PASSENGER_STA]            = T2.[PASSENGER_STA]          --MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [PASSENGER_STA] else null end)
,[TIME_VARIATION_ARRIVAL]    = T2.[TIME_VARIATION_ARRIVAL]  --MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [TIME_VARIATION_ARRIVAL] else null end)
,T2.[AIRCRAFT_TYPE]
,T2.[AIRCRAFT_CONFIGURATION_VERSION]
,T2.[OPERATIONAL_SUFFIX]
,[PASSENGER_TERMINAL_DEPARTURE]  = T1.[PASSENGER_TERMINAL_DEPARTURE] --MAX(case when [LEG_SEQUENCE_NUMBER] = '01' then [PASSENGER_TERMINAL_DEPARTURE] else null end )
,[PASSENGER_TERMINAL_ARRIVAL]    = T2.[PASSENGER_TERMINAL_ARRIVAL]   --MAX(case when [LEG_SEQUENCE_NUMBER] = '02' then [PASSENGER_TERMINAL_ARRIVAL] else null end )
,T2.[PRBD]
,T2.[PRBM]
,T2.[MEAL_SERVICE_NOTE]
,T2.[JOINT_OPERATIONAL_AIRLINE_DESIGNATOR]
,T2.[LEG_DEPARTURE_STATUS]
,T2.[INTERNATIONAL_DOMESTIC_STATUS]
,T2.[ITINERARY_VARIATION_IDENTIFIER_OVERFLOW]
,T2.[AIRCRAFT_OWNER]
,T2.[COCKPIT_CREW_EMPLOYER]
,T2.[CABIN_CREW_EMPLOYER]
,T2.[AIRLINE_DESIGNATOR_ONWARD]
,T2.[FLIGHT_NUMBER_ONWARD]
,T2.[AIRCRAFT_ROTATION_LAYOVER_ONWARD]
,T2.[OPERATIONAL_SUFFIX_ONWARD]
,T2.[FLIGHT_TRANSIT_LAYOVER]
,T2.[CODE_SHARING]
,[TRAFFIC_RESTRICTION_CODE] = T2.[TRAFFIC_RESTRICTION_CODE]         --MAX( [TRAFFIC_RESTRICTION_CODE] )
,T2.[LEG_OVERFLOW_INDICATOR]
,T2.[BILATERAL_INFORMATION]
,[RECORD_SERIAL_NUMBER]     = T2.[RECORD_SERIAL_NUMBER]             --MAX( [RECORD_SERIAL_NUMBER] )
,[ROW_TYPE] = -1
,T2.[ACTIVE],T2.[FILE_NAME],T2.[LOAD_DATE] 
FROM CTE AS T1 INNER JOIN CTE AS T2 
 ON  T1.[AIRLINE_DESIGNATOR] = T2.[AIRLINE_DESIGNATOR] 
 AND T1.[FLIGHT_NUMBER] = T2.[FLIGHT_NUMBER] 
 AND DATEADD (DAY,1,T1.[FLIGHT_DATE] ) = T2.[FLIGHT_DATE]            --T1 stores data for previous date, thus add 1 day to it
WHERE  T2.FLIGHT_UNIQUE_KEY IN (select distinct FLIGHT_UNIQUE_KEY from FlightTypes where [ROW_TYPE] = -1)
)

SELECT * FROM RESULT 
--WHERE [ROW_TYPE] = -1




)


