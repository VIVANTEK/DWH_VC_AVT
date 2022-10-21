
ALTER FUNCTION [dbo].[FT_CALENDAR]()
--==================================================================================================
--Created: 20-Jul-2018                                                       Altered: 16-Sep-2020 
--==================================================================================================

RETURNS  @Result TABLE 
(  DATE_ID   [int]
  ,[D_DATE]  [date] 
  ,[DATE_DESC] [nvarchar](16) 
  ,[DOW_ID]  [int]
  ,[DOW_NAME] [nvarchar](3) 
  ,[DOW_DESC] [nvarchar](20) 
  ,[WEEK_ID]     [int]
  ,[WEEK_NUM]   [int]
  ,[WEEK_NAME]  [nvarchar](2) 
  ,[WEEK_DESC]  [nvarchar](20) 
  ,[MONTH_ID]   [int]
  ,[MONTH_NUM]  [int]
  ,[MONTH_NAME_SHORT] [nvarchar](3) 
  ,[MONTH_NAME_FULL]  [nvarchar](20) 
  ,[MONTH_DESC]  [nvarchar](20)
  ,[QUARTER_ID]  [int]
  ,[QUARTER_NUM]  [int]
  ,[QUARTER_NAME]  [nvarchar](20) 
  ,[QUARTER_DESC]  [nvarchar](20)
  ,[YEAR_ID]  [int]
  ,[MOHTH_DAY_ID]  [int]
  ,[MOHTH_DAY_NAME]    [nvarchar](20)
  ,[YEAR_DAY_ID]      [int]
  ,[YEAR_DAY_NAME] [nvarchar](20)
  )
AS 
BEGIN

DECLARE @StartDate  date = '20150101';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 10, @StartDate));

WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),

d(D_DATE) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
)
INSERT INTO @Result 
SELECT 
 [DATE_ID]          = YEAR(D_DATE) * 10000 + MONTH(D_DATE)*100 + DAY(D_DATE) 
,[D_DATE] 
,[DATE_DESC]        = REPLACE(UPPER(CONVERT(NVARCHAR, D_DATE, 106)) , ' ' , '-')
,[DOW_ID]           = DATEPART(WEEKDAY , D_DATE )
,[DOW_NAME]         = LEFT(UPPER(DATENAME ( WEEKDAY , D_DATE )) ,3 )
,[DOW_DESC]         = UPPER(DATENAME ( WEEKDAY , D_DATE )) 
,[WEEK_ID]          = YEAR(D_DATE) * 100 + DATEPART(WEEK , D_DATE)
,[WEEK_NUM]         = DATEPART ( WEEK , D_DATE) 
,[WEEK_NAME]        = RIGHT ( '0' + DATENAME( WEEK ,  D_DATE )  , 2 ) 
,[WEEK_DESC]        = 'WEEK' + RIGHT ( '0' + DATENAME( WEEK ,  D_DATE )  , 2 ) + '-' + DATENAME ( YEAR ,D_DATE ) 
,[MONTH_ID]         = YEAR(D_DATE) * 100 + DATEPART(MONTH , D_DATE)
,[MONTH_NUM]          = DATEPART( MONTH, D_DATE)
,[MONTH_NAME_SHORT]   = LEFT(UPPER(DATENAME( MONTH, D_DATE)) , 3 )
,[MONTH_NAME_FULL]    = UPPER(DATENAME( MONTH, D_DATE))
,[MONTH_DESC]         = LEFT(UPPER(DATENAME( MONTH, D_DATE)) , 3 ) + '-' + DATENAME ( YEAR ,D_DATE ) 
,[QUARTER_ID]         = YEAR(D_DATE) * 100 + DATEPART(QUARTER , D_DATE)
,[QUARTER_NUM]        = DATEPART( QUARTER, D_DATE)
,[QUARTER_NAME]       = 'Q' + DATENAME( QUARTER, D_DATE) 
,[QUARTER_DESC]       = 'Q' + DATENAME( QUARTER, D_DATE) + '-' + DATENAME ( YEAR ,D_DATE ) 
,[YEAR_ID]            = YEAR(D_DATE) 
,[MOHTH_DAY_ID]      = DATEPART (DAY , D_DATE)
,[MOHTH_DAY_NAME]    = RIGHT('0' + DATENAME (DAY , D_DATE) , 2 )
,[YEAR_DAY_ID]       = DATEPART( DAYOFYEAR, D_DATE)
,[YEAR_DAY_NAME]     = RIGHT('00' + DATENAME( DAYOFYEAR, D_DATE) , 3 )
FROM d

OPTION (MAXRECURSION 0);

    RETURN
END
