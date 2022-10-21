CREATE FUNCTION  [sim].[FT_TMP_PRS_S1]
(@FILE_NAME varchar(255) = NULL)  --Mon,Tue,...,Sun
--==================================================================================================
--Created: 30-Nov-2020                                                       Altered: 04-Dec-2020  
--==================================================================================================
--Returns processed Schedule data drom imported SSIM-file
/*
--Usage example:
SELECT * FROM [sim].[ft_TMP_PRS_S1]('SSIM7PS0001_9999_1047951')  
--WHERE ( CAST([FLIGHT_NUMBER] as int)   = 23 and FLIGHT_DATE = '2022-10-30' )
ORDER BY [FLIGHT_NUMBER],[OPERATION_PERIOD_FROM], [FLIGHT_DATE]
OPTION (MAXRECURSION 3660);
*/
--==================================================================================================
RETURNS TABLE 
AS
RETURN 
(-- DECLARE @FILE_NAME varchar(255) = 'SSIM7PS0001_9999_1041025';
--================================================================================================== 
 WITH FlightLegRecord -- (RecordType = 3) G:\SSDT-2015 Projects\docs\SSIM-Oct2005.pdf ; Тип строки = 3: глава 7, стр. 424
 AS
(SELECT 
  RecordType = SUBSTRING([LINE_TEXT],1,1)
 ,RecordSerialNumber = CAST(SUBSTRING([LINE_TEXT],195,6) as int)
 ,OperationalSuffix = SUBSTRING([LINE_TEXT],2,1)
 ,AirlineDesignator = SUBSTRING([LINE_TEXT],3,3)
 ,FlightNumber =  SUBSTRING([LINE_TEXT],6,4)
 ,ItineraryVariationIdentifier = SUBSTRING([LINE_TEXT],10,2) -- -- номер расписания. например 01 , 02 для первой и второй половины года соответсвенно. каждая половина имеет свое время вылета
 ,LegSequenceNumber = SUBSTRING([LINE_TEXT],12,2)
 ,ServiceType = SUBSTRING([LINE_TEXT],14,1)
 ,OperationPeriodFrom = CAST(SUBSTRING([LINE_TEXT],15,7) as date)
 ,OperationPeriodTo   = CAST(SUBSTRING([LINE_TEXT],22,7) as date)
 ,OperationWeekDayList = REPLACE(SUBSTRING([LINE_TEXT],29,7),' ','0')
 ,FrequencyRate = SUBSTRING([LINE_TEXT],36,1)
 ,DepartureStation = SUBSTRING([LINE_TEXT],37,3)
 ,PassengerSTD = SUBSTRING([LINE_TEXT],40,4)
 ,AircraftSTD  = SUBSTRING([LINE_TEXT],44,4) -- Departure (STD)
 ,TimeVariationDeparture = SUBSTRING([LINE_TEXT],48,5)  -- UTC\Local TimeVariation for Departure Station
 ,PassengerTerminalDeparture  = SUBSTRING([LINE_TEXT],53,2) -- PassengerTerminal for departure station
 ,ArrivalStation = SUBSTRING([LINE_TEXT],55,3)          -- 3-character IATA code
 ,AircraftSTA = SUBSTRING([LINE_TEXT],58,4)             -- ScheduledTimeOfAircraftArrival (STA)
 ,PassengerSTA = SUBSTRING([LINE_TEXT],62,4)            -- Although this time will nearly always be the same as aircraft STA it must be completed
 ,TimeVariationArrival = SUBSTRING([LINE_TEXT],66,5)    -- UTC/Local Time Variation (for Arrival Station)
 ,PassengerTerminalArrival = SUBSTRING([LINE_TEXT],71,2)-- Passenger Terminal for arrival station
 ,AircraftType = SUBSTRING([LINE_TEXT],73,3)
 ,PRBD = SUBSTRING([LINE_TEXT],76,20) -- Passenger Reservations Booking Designator. (76-95) Either this field or the Aircraft Configuration/Version (in bytes 173-192) is mandatory.
 ,PRBM = SUBSTRING([LINE_TEXT],96,5)   --Passenger Reservations Booking Modifier (PRBM)
 ,MealServiceNote = SUBSTRING([LINE_TEXT],101,10)
 ,JointOperationAirlineDesignators = SUBSTRING([LINE_TEXT],111,9)  
 ,LegDepartureStatus = SUBSTRING([LINE_TEXT],120,1) --Leg departure status
 ,InternationalDomesticStatus = SUBSTRING([LINE_TEXT],121,1)     --International/Domestic Status
 --122-127: spaces
 ,ItineraryVariationIdentifierOverflow = SUBSTRING([LINE_TEXT],128,1)
 ,AircraftOwner = SUBSTRING([LINE_TEXT],129,3)
 ,CockpitCrewEmployer = SUBSTRING([LINE_TEXT],132,3)
 ,CabinCrewEmployer = SUBSTRING([LINE_TEXT],135,3)
 ----------------------------------Onward Flight: 138-146 -----------------------------------------
 ,AirlineDesignatorOnward = SUBSTRING([LINE_TEXT],138,3) -- Onward Flight: Airline Designator
 ,FlightNumberOnward = SUBSTRING([LINE_TEXT],141,4)      -- Onward Flight: FlightNumber
 ,AircraftRotationLayoverOnward  = SUBSTRING([LINE_TEXT],145,1) -- Onward Flight:  Aircraft Rotation Layover
 ,OperationalSuffixOnward  = SUBSTRING([LINE_TEXT],146,1) -- Onward Flight: Operational Suffix
 --------------------------------------------------------------------------------------------------
 --147-147: spaces
 ,FlightTransitLayover = SUBSTRING([LINE_TEXT],148,1)
 ,CodeSharing = SUBSTRING([LINE_TEXT],149,1) --  Code Sharing — Commercial Duplicate or Code Sharing — Shared Airline Designation or Wet Lease Airline Designation
 ,TrafficRestrictionCode= SUBSTRING([LINE_TEXT],150,11)
 ,LegOverflowIndicator = SUBSTRING([LINE_TEXT],161,1) --  Traffic Restriction Code Leg Overflow Indicator
 --162-172: spaces
 ,AircraftConfigurationVersion = LTRIM(RTRIM(SUBSTRING([LINE_TEXT],173,20))) --173-192 Aircraft Configuration\Version
 ,BilateralInformation = SUBSTRING([LINE_TEXT],193,2)
 ,[LOAD_TIME] = convert(datetime, convert(char(19), [LOAD_TIME], 126)),[FILE_NAME]
 -----------------------------------------------------------------------------------------------------
-- ,[LINE_TEXT]
FROM [sim].[TMP_PRS_S1]  WITH(NOLOCK)
WHERE LINE_ID >=11 AND SUBSTRING([LINE_TEXT],1,1) = 3
AND ( [FILE_NAME] = @FILE_NAME OR  @FILE_NAME IS NULL)
) -- select * from FlightLegRecord


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
, SegmentDataRecord -- (RecordType = 4) G:\SSDT-2015 Projects\docs\SSIM-Oct2005.pdf ; Тип строки = 4: глава 7, стр. 427
 AS
(SELECT [LOAD_TIME] = convert(datetime, convert(char(19), [LOAD_TIME], 126)),[FILE_NAME]
 ,RecordType = SUBSTRING([LINE_TEXT],1,1)
 ,OperationalSuffix = SUBSTRING([LINE_TEXT],2,1)
 ,AirlineDesignator = SUBSTRING([LINE_TEXT],3,3)
 ,FlightNumber =  SUBSTRING([LINE_TEXT],6,4)
 ,ItineraryVariationIdentifier = SUBSTRING([LINE_TEXT],10,2) -- -- номер расписания. например 01 , 02 для первой и второй половины года соответсвенно. каждая половина имеет свое время вылета
 ,LegSequenceNumber = SUBSTRING([LINE_TEXT],12,2)
 ,ServiceType = SUBSTRING([LINE_TEXT],14,1)
--chars 15...27 = BLANK
 ,ItineraryVariationIdentifierOverflow = SUBSTRING([LINE_TEXT],28,1) --Empty Field, fo not need it
 --===========================================================================================================
 --Three columns below all together constitute a data-element number. For example, DataElementNum = 'AB050' 
 --if exists, means that the next 5 chars will show operational airline + flight number
 --There can be other values for data-element number, for example "AB127", but now we do not care for them, 
 --and care only for "AB060". Thus I'll make one filed instead of 3
 ,BoardPointIndicator = SUBSTRING([LINE_TEXT],29,1),OffPointIndicator = SUBSTRING([LINE_TEXT],30,1)  
 ,DataElementIdentifier  = SUBSTRING([LINE_TEXT],31,3)
 ,DataElementNum = SUBSTRING([LINE_TEXT],29,5)
  --=========================================================================================================== 
 ,BoardPoint = SUBSTRING([LINE_TEXT],34,3) --left part of segment
 ,OffPoint = SUBSTRING([LINE_TEXT],37,3)   --right part f segment
 ,AirlineDesignatorOP = CASE SUBSTRING([LINE_TEXT],29,5) -- DataElement = "AB127" ?
                          WHEN  'AB050'   THEN  SUBSTRING([LINE_TEXT],40,2) 
						  ELSE ''
						END
 ,FlightNumberOP =      CASE SUBSTRING([LINE_TEXT],29,5) -- DataElement = "AB127" ?
                          WHEN  'AB050'   THEN   SUBSTRING([LINE_TEXT],42,5) 
						  ELSE ''
						END 
 --chars 40...194 = BLANK
,RecordSerialNumber = CAST(SUBSTRING([LINE_TEXT],195,6) as int)
FROM [sim].[TMP_PRS_S1]  WITH(NOLOCK)
WHERE LINE_ID >=11 AND SUBSTRING([LINE_TEXT],1,1) = 4
AND  [FILE_NAME] = @FILE_NAME OR  @FILE_NAME IS NULL
)-- select * from SegmentDataRecord where FlightNumber = '9085'
 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


 SELECT  
 [RECORD_SERIAL_NUMBER] = FLT.RecordSerialNumber 
,[RECORD_TYPE] = FLT.RecordType	
,[AIRLINE_DESIGNATOR] = RTRIM(LTRIM(FLT.AirlineDesignator))	
,[FLIGHT_NUMBER] =  RIGHT( '00000' + RTRIM(LTRIM(FLT.FlightNumber ))  , 5)	
,[AIRLINE_DESIGNATOR_OP] = RTRIM(LTRIM( ISNULL(SEG.AirlineDesignatorOP, FLT.AirlineDesignator) ))
,[FLIGHT_NUMBER_OP] = RIGHT( '00000' + RTRIM(LTRIM(  ISNULL(SEG.FlightNumberOP,FLT.FlightNumber))) , 5)
,[ITINERARY_VARIATION_IDENTIFIER] = FLT.ItineraryVariationIdentifier	
,[LEG_SEQUENCE_NUMBER] = FLT.LegSequenceNumber	
,[SERVICE_TYPE] = FLT.ServiceType	
,[OPERATION_PERIOD_FROM] = FLT.OperationPeriodFrom	
,[OPERATION_PERIOD_TO] = FLT.OperationPeriodTo	
,[FLIGHT_DATE] = CAL.DateValue 
,[FLIGHT_DOW_NAME] = CAST(LEFT(CAL.DayOfWeekName,3) as varchar(3))
,[FLIGHT_DOW_NUM]  = CAST(CAL.DayOfWeekNum as int)
,[OPERATION_WEEKDAY_LIST] = CAST(FLT.OperationWeekDayList as varchar(7))	
,[FREQUENCY_RATE] = FLT.FrequencyRate	
,[DEPARTURE_STATION] = FLT.DepartureStation	
,[PASSENGER_STD]            = CAST(LEFT(FLT.PassengerSTD,2) + ':' + RIGHT(FLT.PassengerSTD,2) as time)
,[AIRCRAFT_STD]             = CAST(LEFT(FLT.AircraftSTD,2) + ':' + RIGHT(FLT.AircraftSTD,2) as time)
,[TIME_VARIATION_DEPARTURE]  = SUBSTRING(FLT.TimeVariationDeparture,1,LEN(FLT.TimeVariationDeparture)-2) + ':' + RIGHT(FLT.TimeVariationDeparture,2)	
,[ARRIVAL_STATION] = FLT.ArrivalStation	
,[AIRCRAFT_STA]             = CAST(LEFT(FLT.AircraftSTA, 2) + ':' + RIGHT(FLT.AircraftSTA, 2) as time)
,[PASSENGER_STA]            = CAST(LEFT(FLT.PassengerSTA,2) + ':' + RIGHT(FLT.PassengerSTA,2) as time)
,[TIME_VARIATION_ARRIVAL]    = SUBSTRING(FLT.TimeVariationArrival,1,LEN(FLT.TimeVariationArrival)-2) + ':' + RIGHT(FLT.TimeVariationArrival,2)	
,[AIRCRAFT_TYPE] = FLT.AircraftType
,[AIRCRAFT_CONFIGURATION_VERSION] = AircraftConfigurationVersion	
--,AircraftConfigurationVersion = CASE PATINDEX('%[0-9]%',AircraftConfigurationVersion) 
--                                  WHEN 1 THEN REPLACE(REPLACE(REPLACE(AircraftConfigurationVersion,'C','C|'),'S','S|'),'W','W|')
--                                  ELSE REPLACE(REPLACE(REPLACE(AircraftConfigurationVersion,'C','|C'),'S','|S'),'W','|W') 
--                                END 
--============ usually empty fields ========================
,[OPERATIONAL_SUFFIX] = FLT.OperationalSuffix
,[PASSENGER_TERMINAL_DEPARTURE] = FLT.PassengerTerminalDeparture
,[PASSENGER_TERMINAL_ARRIVAL] = FLT.PassengerTerminalArrival
,[PRBD] = FLT.PRBD
,[PRBM] = FLT.PRBM
,[MEAL_SERVICE_NOTE] = FLT.MealServiceNote
,[JOINT_OPERATIONAL_AIRLINE_DESIGNATOR] = FLT.JointOperationAirlineDesignators
,[LEG_DEPARTURE_STATUS] = FLT.LegDepartureStatus
,[INTERNATIONAL_DOMESTIC_STATUS] = FLT.InternationalDomesticStatus
,[ITINERARY_VARIATION_IDENTIFIER_OVERFLOW] = FLT.ItineraryVariationIdentifierOverflow
,[AIRCRAFT_OWNER] = FLT.AircraftOwner
,[COCKPIT_CREW_EMPLOYER] = FLT.CockpitCrewEmployer
,[CABIN_CREW_EMPLOYER] = FLT.CabinCrewEmployer
,[AIRLINE_DESIGNATOR_ONWARD] = FLT.AirlineDesignatorOnward
,[FLIGHT_NUMBER_ONWARD] = FLT.FlightNumberOnward
,[AIRCRAFT_ROTATION_LAYOVER_ONWARD] = FLT.AircraftRotationLayoverOnward
,[OPERATIONAL_SUFFIX_ONWARD] = FLT.OperationalSuffixOnward
,[FLIGHT_TRANSIT_LAYOVER] = FLT.FlightTransitLayover
,[CODE_SHARING] = FLT.CodeSharing
,[TRAFFIC_RESTRICTION_CODE] = FLT.TrafficRestrictionCode
,[LEG_OVERFLOW_INDICATOR] = FLT.LegOverflowIndicator
,[BILATERAL_INFORMATION] = FLT.BilateralInformation
-----------------------------------------------------
,ACTIVE = 1
,[FILE_NAME] = FLT.[FILE_NAME]
,[LOAD_TIME] = FLT.[LOAD_TIME]

FROM FlightLegRecord AS FLT
CROSS APPLY [dbo].[FT_DATE_RANGE](OperationPeriodFrom, OperationPeriodTo,'d',default) AS CAL
OUTER APPLY 
           ( select top 1 AirlineDesignatorOP,FlightNumberOP,RecordSerialNumber,DataElementNum --top 1
		     from SegmentDataRecord AS SEG  
			 where SEG.[FILE_NAME] = FLT.[FILE_NAME] and  FLT.[LOAD_TIME] = SEG.[LOAD_TIME]
			   and SEG.RecordSerialNumber between FLT.RecordSerialNumber+1  and  FLT.RecordSerialNumber+4
			   and SEG.DataElementNum = 'AB050'  --and SEG.FlightNumber	= '9085'
		  ) AS SEG
WHERE CHARINDEX(CAL.DayOfWeekNum, FLT.OperationWeekDayList) > 0 -- and FLT.FlightNumber	= '9085'
--OPTION (MAXRECURSION 3660); --=576

)


--====================================================================================================
/* NOT USED YET, BUT MAYBE NEEDED IN FUTURE
Header AS
(SELECT [LOAD_TIME] = convert(datetime, convert(char(19), [LOAD_TIME], 126))
 ,[FILE_NAME]
 ,RecordType = SUBSTRING([LINE_TEXT],1,1)
 ,TimeMode   = SUBSTRING([LINE_TEXT],2,1) --U = UTC, L = Local Time
 --spaces: 6..10  )
 ,Season   = SUBSTRING([LINE_TEXT],11,3)
 --spaces: 14..14  )
 ,ScheduleValidityFrom = SUBSTRING([LINE_TEXT],15,7) -- 29MAR20 24OCT20 25NOV19 
 ,ScheduleValidityTo   = SUBSTRING([LINE_TEXT],22,7)
 ,CreationDate   = SUBSTRING([LINE_TEXT],29,7)
 ,TitleOfData  = SUBSTRING([LINE_TEXT],36,29)
 ,ReleaseDate  = SUBSTRING([LINE_TEXT],65,3) -- 65 71 Release (Sell) Date
 ,ScheduleStatus  = SUBSTRING([LINE_TEXT],72,1) -- P or C
FROM [ONDBDG].[dbo].[IMP_SSIM_TXT] WITH(NOLOCK) 
WHERE SUBSTRING([LINE_TEXT],1,1) = 2 
)
--====================================================================================================
,CAL AS
(SELECT DateValue
       ,DayOfWeekName
	   ,DayOfWeekNum
FROM [dbo].[ft_DateRange](
                       (select min(OperationPeriodFrom) from FlightLeg)
                      ,(select max(OperationPeriodTo)   from FlightLeg)
                      ,'d',default
					   ) AS F
)--select * from CAL  OPTION (MAXRECURSION 3660);
--====================================================================================================
*/

