
CREATE PROCEDURE [dbo].[P_UPDATE_FCT_PROFIT_LOSS_FEED]         
AS
--====================================================================
--Created: 11-Aug-2022                           Altered: 11-Aug-2022       
--====================================================================
--This procedure  refills table dbo.FCT_PROFIT_LOSS_FEED
--====================================================================
/*
 exec sp_recompile '[P_UPDATE_FCT_PROFIT_LOSS_FEED]' 
 --------------------------------------------------------------------
 EXEC [dbo].[P_UPDATE_FCT_PROFIT_LOSS_FEED] 
 SELECT * FROM [dbo].[FCT_PROFIT_LOSS_FEED]
 --------------------------------------------------------------------
 --TRUNCATE TABLE [dbo].[FCT_PROFIT_LOSS_FEED]
 --------------------------------------------------------------------
*/
--=====================================================================

BEGIN
SET NOCOUNT ON; 
BEGIN TRY 

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TRUNCATE TABLE [dbo].[FCT_PROFIT_LOSS_FEED]
INSERT INTO [dbo].[FCT_PROFIT_LOSS_FEED]
      ([PNL_ITEM],[FLIGHT],  [MONTH_ID],[VERSION])
SELECT [PNL_ITEM],[FLT_DESC],[MONTH_ID],[VERSION]='FCST'
FROM
(
	SELECT PNL_ITEM = 'Departures', FLT_DESC, MONTH_ID = FORMAT(FLIGHT_DATE, 'yyyyMM'),PNL_AMOUNT = DEPARTURES 
	FROM V_FCT_SCHEDULE_FLIGHT_PTP
	UNION ALL
	SELECT PNL_ITEM = 'BH', FLT_DESC, MONTH_ID = FORMAT(FLIGHT_DATE, 'yyyyMM'),PNL_AMOUNT =  BH 
	FROM V_FCT_SCHEDULE_FLIGHT_PTP
	UNION ALL
	SELECT PNL_ITEM = 'Seats', FLT_DESC, MONTH_ID = FORMAT(FLIGHT_DATE, 'yyyyMM'), PNL_AMOUNT = SEATS 
	FROM V_FCT_SCHEDULE_FLIGHT_PTP
	UNION ALL
	SELECT PNL_ITEM = 'Seats C', FLT_DESC, MONTH_ID = FORMAT(FLIGHT_DATE, 'yyyyMM'), PNL_AMOUNT = SEATS_C
	FROM V_FCT_SCHEDULE_FLIGHT_PTP
	UNION ALL
	SELECT PNL_ITEM = 'Seats Y', FLT_DESC, MONTH_ID = FORMAT(FLIGHT_DATE, 'yyyyMM'), PNL_AMOUNT = SEATS_S 
	FROM V_FCT_SCHEDULE_FLIGHT_PTP
	UNION ALL
	SELECT PNL_ITEM = 'Seats Y+', FLT_DESC, MONTH_ID = FORMAT(FLIGHT_DATE, 'yyyyMM'), PNL_AMOUNT = SEATS_W
	FROM V_FCT_SCHEDULE_FLIGHT_PTP
)T 
WHERE PNL_AMOUNT <> 0 
GROUP BY PNL_ITEM, FLT_DESC, MONTH_ID
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
END TRY 
BEGIN CATCH 
  --RAISERROR ('Error raised in [dbo].[pUpdateProductionCubeData_TTL]',16,1);  
  EXEC [dbo].[P_LOG_ERROR] N'Error raised in [dbo].[P_UPDATE_FCT_PROFIT_LOSS_FEED]'
                          ,N'[dbo].[P_UPDATE_FCT_PROFIT_LOSS_FEED]' ;
  --SELECT * FROM [dbo].[LOG_ERROR]
END CATCH; 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
--Return resulted rows
SELECT * FROM [dbo].[FCT_PROFIT_LOSS_FEED]

SET NOCOUNT OFF;

END

