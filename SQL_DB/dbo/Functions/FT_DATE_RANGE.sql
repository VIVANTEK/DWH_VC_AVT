
-- WE ALREADY GAVE THIS FUNCTION IN DWH_STG WITH A BIT ANOTHER NAME = [dbo].[fDateRange], but it does not work correctly with SSIM data
CREATE FUNCTION [dbo].[FT_DATE_RANGE]
(@StartDate   datetime
,@EndDate     datetime
,@Increment   char(1) = 'd' --d=day; w=week; m-month
,@WeekDayName varchar(20))  --Mon,Tue,...,Sun
--==================================================================================================
--Created: 30-Nov-2020                                                        Altered: 30-Nov-2020   
--==================================================================================================
--Outputs a date range
--See: https://www.mssqltips.com/sqlservertip/2800/sql-server-function-to-return-a-range-of-dates/
/*
--Usage example:
select * from [dbo].[ft_DateRange] ('20170801','20180801','d','Tue') ORDER BY DateValue OPTION (MAXRECURSION 3660);
select * from [dbo].[ft_DateRange] ('20170801','20180801','w','Tue') OPTION (MAXRECURSION 3660);
select * from [dbo].[ft_DateRange] ('20170803','20180803','w', default)  OPTION (MAXRECURSION 3660);
select * from [dbo].[ft_DateRange] ('20170805','20180805','m', default)  OPTION (MAXRECURSION 3660);
---------------------------------------------------------------------------------------------------
--                       ISO_WEEK datepart
--Стандарт ISO 8601 включает в себя систему отсчета дней и недель ISO. 
--Каждая неделя приписывается тому году, в котором находится ее четверг. 
--Например, 1-я неделя 2004 г. (2004W01) считается с понедельника 29 декабря 2003 г.
--по воскресенье 4 января 2004 г. Наибольшее число недель в году может составлять 52 или 53. 
--Этот стиль нумерации обычно используется в странах и регионах Европы, но редко в других странах.
*/
--==================================================================================================
RETURNS TABLE 
AS
RETURN 
(
      WITH cteRange (DateRange) 
	  AS (
            SELECT @StartDate
            UNION ALL
            SELECT 
                  CASE
                        WHEN @Increment = 'd' THEN DATEADD(dd, 1, DateRange)
                        WHEN @Increment = 'w' THEN DATEADD(ww, 1, DateRange)
                        WHEN @Increment = 'm' THEN DATEADD(mm, 1, DateRange)
                  END
            FROM cteRange
            WHERE DateRange <= 
                  CASE
                        WHEN @Increment = 'd' THEN DATEADD(dd, -1, @EndDate)
                        WHEN @Increment = 'w' THEN DATEADD(ww, -1, @EndDate)
                        WHEN @Increment = 'm' THEN DATEADD(mm, -1, @EndDate)
                  END)
          

      SELECT DateValue= CAST(DateRange as date)   
            ,YearNum  = DATEPART (year,  DateRange)    
            ,MonthNum = DATEPART (month, DateRange)  
            ,WeekNum = DATEPART (week,  DateRange)   
            ,WeekNum_ISO = DATEPART (ISOWK, DateRange)   
            ,DayOfYearNum = DATEPART (dayofyear,DateRange)  
          --,DayOfWeekNum = DATEPART (weekday,DateRange)  
            ,DayOfWeekNum = CASE DATENAME(DW, DateRange)
                              WHEN 'Monday'    THEN '1'
                              WHEN 'Tuesday'   THEN '2'
                              WHEN 'Wednesday' THEN '3'
                              WHEN 'Thursday'  THEN '4'
                              WHEN 'Friday'    THEN '5'
                              WHEN 'Saturday'  THEN '6'
                              WHEN 'Sunday'    THEN '7'
                            END
            ,DayOfWeekName = DATENAME(DW, DateRange)            
      FROM cteRange 
	  WHERE (UPPER(LEFT(DATENAME(DW, DateRange),3)) = UPPER(LEFT(@WeekDayName,3)) )
	      OR LTRIM(RTRIM(ISNULL(@WeekDayName,''))) = ''
    --  OPTION (MAXRECURSION 3660);
)
 


