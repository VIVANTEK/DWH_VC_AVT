
Create FUNCTION [dbo].[FT_TIME_RANGE]()
--==================================================================================================
--Created: 20-Jul-2018                                                       Altered: 16-Sep-2020 
--==================================================================================================

RETURNS  @Result TABLE 
([RNG_ID] [int] NULL
,[PERIOD_B] [int] NULL
,[PERIOD_E] [int] NULL
,[PERIOD_HH] [int] NULL
,[PERIOD_B_MIN] [int] NULL
,[PERIOD_E_MIN] [int] NULL
,[TIME_RANGE] [nvarchar] (4000) NULL
,[QUALITY_CONNECTION] [nvarchar](16) NOT NULL)
AS 
BEGIN

	;WITH dates  (  i , period_b , period_e)  as
	(select 1,  0 , 4
     union all
     select  i + 1 , period_b + 5  , period_b + 10 -1
     from dates where period_b < 1435
	) 


	INSERT INTO @Result
            (RNG_ID, 
			PERIOD_B, 
			PERIOD_E, 
			PERIOD_HH, 
			PERIOD_B_MIN, 
			PERIOD_E_MIN, 
			TIME_RANGE, 
			QUALITY_CONNECTION)

    select  RNG_ID=0, PERIOD_B =0, PERIOD_E=0, PERIOD_HH=0, PERIOD_B_MIN=0, PERIOD_E_MIN=0, TIME_RANGE = 'XX:XX - XX:XX', QUALITY_CONNECTION = 'No Connection'
	
	UNION

	select  
	RNG_ID = i , 
	PERIOD_B , 
	PERIOD_E ,  
	PERIOD_B  /  60   as PERIOD_HH , 
	PERIOD_B  -  60 * (PERIOD_B / 60) as PERIOD_B_MIN , 
	PERIOD_E  -  60 * (period_b / 60) as PERIOD_E_MIN ,  
	TIME_RANGE = FORMAT(PERIOD_B / 60 ,'00')  + ':' + FORMAT(PERIOD_B  -  60 * (PERIOD_B / 60) , '00') 
	          + ' - ' +
                FORMAT(PERIOD_B / 60 ,'00')  + ':' + FORMAT(PERIOD_E  -  60 * (PERIOD_B / 60) , '00') ,
	QUALITY_CONNECTION = 
         case
	        when PERIOD_B < 45 then 'No Connection'
            when PERIOD_B >=  45  and PERIOD_B < 210  then'Good Connection'
			when PERIOD_B >=  210 and PERIOD_B < 315 then 'Midle Connection'
			when PERIOD_B >=  315  then 'Bad Connection' 
			else 'Other Connection' 
         end  
	from dates 
	OPTION (MAXRECURSION 3660);

    RETURN
END



