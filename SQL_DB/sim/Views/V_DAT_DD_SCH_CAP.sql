


 

-- select * from [sim].[V_DAT_DD_SCH_CAP]
CREATE VIEW [sim].[V_DAT_DD_SCH_CAP]
--===================================================================================
--Created:  02-Dec-2020                                        Altered:  04-Dec-2020    
--===================================================================================
--Used as a source for insering data into [DWH_STG].[dbo].[IMP_SSIM_ACT]
--inside ssis-package G:\SSDT-2015 Projects\SSIS\PROD\SSIM\SSIM\SSIM_LoadTables.dtsx
/*
--run this view
select * from [sim].[V_DAT_DD_SCH_CAP]
*/
--===================================================================================
AS

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
WITH  PARSE_CAP 
AS
( SELECT [CAPACITY_TYPE] = CASE 
							  when RC = 1 then 'S'
							  ------------------------------------------------------------------------------------------------------------
							  when RC = 2 and ID = 1 then 'C'
							  when RC = 2 and ID = 2 then 'S'
							  ------------------------------------------------------------------------------------------------------------
							  when RC = 3 and ID = 1 then 'C'
							  when RC = 3 and ID = 2 then 'W'
							  when RC = 3 and ID = 3 then 'S'
							  else 'X'
                        END
		,[CAPACITY] = TRY_CAST([CAPACITY] AS int)
		,[AIRCRAFT_CONFIGURATION_VERSION] --,ID,RC
  FROM
   (SELECT DISTINCT [AIRCRAFT_CONFIGURATION_VERSION],[CAPACITY],[ID],[RC] 
	FROM [sim].[DAT_DD_SCH] AS T1 WITH(NOLOCK)
	CROSS APPLY 
	   (select ID = F.ItemNumber/2
	          ,RC = (select count(*) from [dbo].[FT_SPLIT_STRING](T1.[AIRCRAFT_CONFIGURATION_VERSION],'[0-9]') where [Matched] = 1 )
		      ,[CAPACITY] = [Item]
       from  [dbo].[FT_SPLIT_STRING](T1.[AIRCRAFT_CONFIGURATION_VERSION],'[0-9]') as F where F.Matched = 1 	 
	   ) AS T2
	WHERE PATINDEX('%[0-9]%',[AIRCRAFT_CONFIGURATION_VERSION]) > 0 AND [ACTIVE] = 1
   ) T
 
)--  select *  from PARSE_CAP order by [AIRCRAFT_CONFIGURATION_VERSION]
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
,CAP 
AS
(SELECT [AIRCRAFT_CONFIGURATION_VERSION]
      , [CAPACITY_C] = SUM([CAPACITY_C])
	  , [CAPACITY_W] = SUM([CAPACITY_W])
	  , [CAPACITY_S] = SUM([CAPACITY_S])
 FROM
  (SELECT [AIRCRAFT_CONFIGURATION_VERSION], [CAPACITY_C] = [CAPACITY], [CAPACITY_W] = 0, [CAPACITY_S] = 0 
   FROM PARSE_CAP WHERE [CAPACITY_TYPE] = 'C' UNION
   SELECT [AIRCRAFT_CONFIGURATION_VERSION], [CAPACITY_C] = 0, [CAPACITY_W] = CAPACITY, [CAPACITY_S] = 0 
   FROM PARSE_CAP WHERE [CAPACITY_TYPE] = 'W' UNION
  SELECT [AIRCRAFT_CONFIGURATION_VERSION], [CAPACITY_C] = 0, [CAPACITY_W] = 0, [CAPACITY_S] = [CAPACITY]
   FROM PARSE_CAP WHERE [CAPACITY_TYPE] = 'S' )T
 GROUP BY  [AIRCRAFT_CONFIGURATION_VERSION]
) -- select * from CAP
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
,RESULT 
AS
(SELECT DISTINCT 
       T1.[AIRLINE_DESIGNATOR] ,T1.[FLIGHT_NUMBER]
      ,T1.[AIRLINE_DESIGNATOR_OP] ,T1.[FLIGHT_NUMBER_OP]
      ,T1.[DEPARTURE_STATION] ,T1.[ARRIVAL_STATION]
	  ,T1.[TIME_VARIATION_DEPARTURE], T1.[TIME_VARIATION_ARRIVAL]
      ,[DEPARTURE_DATE] = CAST([FLIGHT_DATE] AS datetime) + CAST([AIRCRAFT_STD] AS datetime)
      ,[ARRIVAL_DATE]   = CASE
	                        WHEN [AIRCRAFT_STD] < [AIRCRAFT_STA] THEN CAST([FLIGHT_DATE] AS datetime) 
							ELSE CAST(DATEADD(DAY,1,[FLIGHT_DATE]) AS datetime)
					     END + CAST([AIRCRAFT_STA] AS datetime)
	  ,T1.[AIRCRAFT_TYPE]
      ,T1.[AIRCRAFT_CONFIGURATION_VERSION]
      ,[CAPACITY_C] = ISNULL(T2.[CAPACITY_C],0)
      ,[CAPACITY_W] = ISNULL(T2.[CAPACITY_W],0)
      ,[CAPACITY_S] = ISNULL(T2.[CAPACITY_S],0)
      ,T1.[LOAD_DATE]
FROM [sim].[DAT_DD_SCH] AS T1 WITH(NOLOCK)
  LEFT JOIN CAP AS T2 
  ON T1.[AIRCRAFT_CONFIGURATION_VERSION] = T2.[AIRCRAFT_CONFIGURATION_VERSION]
) -- select * from RESULT
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SELECT 
     [AIRLINE_DESIGNATOR]
	,[FLIGHT_NUMBER]
	,[AIRLINE_DESIGNATOR_OP]
	,[FLIGHT_NUMBER_OP]
	,[DEPARTURE_STATION]
	,[ARRIVAL_STATION]
    ---------------------------------------------------------------------
	,[DEPARTURE_DATE]  -- = local time at the departure airport
	,[TIME_VARIATION_DEPARTURE]
	--Departure UTC time = local time + ( [TIME_VARIATION_DEPARTURE] ) *(-1)
	,[DEPARTURE_DATE_UTC] = DATEADD(minute 
	                           ,DateDiff(minute, [DEPARTURE_DATE], TODATETIMEOFFSET ([DEPARTURE_DATE],[TIME_VARIATION_DEPARTURE]) ) 
							   ,[DEPARTURE_DATE]) 

	,[ARRIVAL_DATE]    -- = local time at the arrival airport
    ,[TIME_VARIATION_ARRIVAL]
    --Arrival UTC time = local time + ( [TIME_VARIATION_ARRIVAL] ) *(-1)	
	,[ARRIVAL_DATE_UTC]   = DATEADD(minute 
	                           ,DateDiff(minute, [ARRIVAL_DATE], TODATETIMEOFFSET ([ARRIVAL_DATE],[TIME_VARIATION_ARRIVAL]) ) 
							   ,[ARRIVAL_DATE])        
    ---------------------------------------------------------------------
	,[AIRCRAFT_TYPE]
	,[AIRCRAFT_CONFIGURATION_VERSION]
	,[CAPACITY_C]
	,[CAPACITY_W]
	,[CAPACITY_S]
	,[LOAD_DATE]
FROM RESULT

/*
SELECT CONVERT(DATETIME2(0), '2015-03-29T01:01:00', 126)     
AT TIME ZONE 'Central European Standard Time';  
--Result: 2015-03-29 01:01:00 +01:00  
 
DECLARE @todaysDateTime DATETIME;  
SET @todaysDateTime = GETDATE();  
SELECT today1=@todaysDateTime, today2= TODATETIMEOFFSET (@todaysDateTime, '+01:00')   -- 2020-12-04 17:09:08.073 +01:00
, today3=  DateDiff(minute, @todaysDateTime, TODATETIMEOFFSET (@todaysDateTime, '+01:00') ) 
*/








