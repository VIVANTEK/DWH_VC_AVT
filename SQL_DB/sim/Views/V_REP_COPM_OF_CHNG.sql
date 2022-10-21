-- select * from [sim].[V_REP_COPM_OF_CHNG]  
CREATE VIEW [sim].[V_REP_COPM_OF_CHNG]   
AS 
--=======================================================================================
WITH Report_date
AS (
	SELECT TOP 2 [LOAD_DATE]
		,RANK() OVER (
			ORDER BY [LOAD_DATE] DESC
			) AS N
	FROM [sim].[DAT_DD_SCH] WITH (NOLOCK)
	GROUP BY [LOAD_DATE]
	)
--=======================================================================================
,Report_data
AS (
	SELECT N
		,sch.[LOAD_DATE]
		,[FLIGHT_DATE]
		,[AIRLINE_DESIGNATOR]
		,[FLIGHT_NUMBER]
		,[DEPARTURE_STATION]
		,[ARRIVAL_STATION]
		,[OPERATION_PERIOD_FROM]
		,[OPERATION_PERIOD_TO]
		,[OPERATION_WEEKDAY_LIST] = Replace([OPERATION_WEEKDAY_LIST], '0', '_')
		,[STD_LT] = [AIRCRAFT_STD]
		,[STA_LT] = [AIRCRAFT_STA]
		,[TIME_VARIATION_DEPARTURE]
		,[TIME_VARIATION_ARRIVAL]
		,cast(DATEADD(minute, DateDiff(minute, cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STD] AS DATETIME), TODATETIMEOFFSET(cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STD] AS DATETIME), [TIME_VARIATION_DEPARTURE])), cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STD] AS DATETIME)) AS TIME) AS STD_UTC
		,cast(DATEADD(minute, DateDiff(minute, cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STA] AS DATETIME), TODATETIMEOFFSET(cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STA] AS DATETIME), [TIME_VARIATION_ARRIVAL])), cast(cast(getdate() AS DATE) AS DATETIME) + CAST([AIRCRAFT_STA] AS DATETIME)) AS TIME) AS STA_UTC
	FROM SIM.DAT_DD_SCH sch
	JOIN Report_date ON sch.[LOAD_DATE] = Report_date.[LOAD_DATE]
	WHERE [OPERATION_PERIOD_TO] >= cast(getdate() AS DATE)
	  AND [FLIGHT_DATE] >= cast(getdate() AS DATE)
      AND [AIRLINE_DESIGNATOR_OP] = 'PS' 
  -- AND [FLIGHT_NUMBER] = '00111'  
	) --SELECT * FROM Report_data
	--=======================================================================================


SELECT DISTINCT 
     [AIRLINE_DESIGNATOR]
	,[FLIGHT_NUMBER]
	,[DEPARTURE_STATION]
	,[ARRIVAL_STATION]
	,[CUR_OPERATION_PERIOD_FROM]
	,[CUR_OPERATION_PERIOD_TO]
	,[CUR_OPERATION_WEEKDAY_LIST]
	,[CUR_STD_LT]
	,[CUR_STA_LT]
	,[CUR_STD_UTC]
	,[CUR_STA_UTC]
	,[PREV_OPERATION_PERIOD_FROM]
	,[PREV_OPERATION_PERIOD_TO]
	,[PREV_OPERATION_WEEKDAY_LIST]
	,[PREV_STD_LT]
	,[PREV_STA_LT]
	,[PREV_STD_UTC]
	,[PREV_STA_UTC]
	--------------Diff---------------
	,[DIFF_OPERATION_PERIOD_FROM]
	,[DIFF_OPERATION_PERIOD_TO]
	,[DIFF_OPERATION_WEEKDAY_LIST]
	,[DIFF_STD_LT]
	,DIFF_STA_LT
FROM (
	SELECT [FLIGHT_DATE]
		,[AIRLINE_DESIGNATOR]
		,[FLIGHT_NUMBER]
		,[DEPARTURE_STATION]
		,[ARRIVAL_STATION]
		,[CUR_OPERATION_PERIOD_FROM] = MAX(CASE 
                                             WHEN N = 1 THEN [OPERATION_PERIOD_FROM]
                                             ELSE NULL
                                           END)
		,[CUR_OPERATION_PERIOD_TO] = MAX(CASE 
                                          WHEN N = 1 THEN [OPERATION_PERIOD_TO]
                                          ELSE NULL
                                         END)
		,[CUR_OPERATION_WEEKDAY_LIST] = MAX(CASE 
                                             WHEN N = 1 THEN [OPERATION_WEEKDAY_LIST]
                                             ELSE NULL
                                            END)
		,[CUR_STD_LT] = MAX(CASE WHEN N = 1	THEN [STD_LT] ELSE NULL	END)
		,[CUR_STA_LT] = MAX(CASE WHEN N = 1	THEN [STA_LT] ELSE NULL END)
		--MAX(case when N= 1 then TimeVariationDeparture else null end)     CUR_TimeVariationDeparture ,
		--MAX(case when N= 1 then TimeVariationArrival else null end)       CUR_TimeVariationArrival,
		,[CUR_STD_UTC] = MAX(CASE WHEN N = 1 THEN [STD_UTC] ELSE NULL END)
		,[CUR_STA_UTC] = MAX(CASE WHEN N = 1 THEN [STA_UTC] ELSE NULL END)
		---------------------Prev-------------------------
		,[PREV_OPERATION_PERIOD_FROM] = MAX(CASE 
				WHEN N = 2 THEN [OPERATION_PERIOD_FROM]	ELSE NULL END)
		,[PREV_OPERATION_PERIOD_TO] = MAX(CASE WHEN N = 2 THEN [OPERATION_PERIOD_TO] ELSE NULL END)
		,[PREV_OPERATION_WEEKDAY_LIST] = MAX(CASE WHEN N = 2 THEN [OPERATION_WEEKDAY_LIST] ELSE NULL END)
		,[PREV_STD_LT] = MAX(CASE WHEN N = 2 THEN STD_LT ELSE NULL END)
		,[PREV_STA_LT] = MAX(CASE WHEN N = 2 THEN STA_LT ELSE NULL END)
		--MAX(case when N= 2 then TimeVariationDeparture else null end)     PREV_TimeVariationDeparture ,
		--MAX(case when N= 2 then TimeVariationArrival else null end)       PREV_TimeVariationArrival,
		,[PREV_STD_UTC] = MAX(CASE WHEN N = 2 THEN STD_UTC ELSE NULL END)
		,[PREV_STA_UTC] = MAX(CASE WHEN N = 2 THEN STA_UTC ELSE NULL END)
		--------------Diff---------------
		,[DIFF_OPERATION_PERIOD_FROM] = CASE 
		                                  WHEN MAX(CASE 
		                                                WHEN N = 1 THEN [OPERATION_PERIOD_FROM] 
		                                                ELSE NULL 
												    END) = MAX(CASE 
													             WHEN N = 2 THEN [OPERATION_PERIOD_FROM]
						                                         ELSE NULL 
															   END)
				                               THEN 0
			                                   ELSE 1
		                                END
		,[DIFF_OPERATION_PERIOD_TO] = CASE 
			                             WHEN MAX(CASE 
						                            WHEN N = 1 THEN [OPERATION_PERIOD_TO]
						                            ELSE NULL
					                              END) = MAX(CASE 
						                                       WHEN N = 2 THEN [OPERATION_PERIOD_TO]
						                                       ELSE NULL
						                                     END)
			                             THEN 0
			                             ELSE 1
			                          END
		,[DIFF_OPERATION_WEEKDAY_LIST] = CASE 
			                               WHEN MAX(CASE 
						                              WHEN N = 1 THEN [OPERATION_WEEKDAY_LIST]
						                              ELSE NULL
                                                    END) = MAX(CASE 
                                                                WHEN N = 2 THEN [OPERATION_WEEKDAY_LIST]
						                                        ELSE NULL
						                                       END)
                                           THEN 0
                                           ELSE 1
			                             END
		,[DIFF_STD_LT] = CASE 
                           WHEN MAX(CASE 
                                     WHEN N = 1 THEN STD_LT
						             ELSE NULL
						            END) = MAX(CASE WHEN N = 2 THEN STD_LT ELSE NULL END)
				           THEN 0
			               ELSE 1
                        END
		,[DIFF_STA_LT] = CASE 
                           WHEN MAX(CASE 
						              WHEN N = 1 THEN STA_LT
						              ELSE NULL
						            END) = MAX(CASE WHEN N = 2 THEN STA_LT ELSE NULL END)
                           THEN 0
                           ELSE 1
                        END
	FROM Report_data
	GROUP BY [FLIGHT_DATE],[AIRLINE_DESIGNATOR],[FLIGHT_NUMBER],[DEPARTURE_STATION],[ARRIVAL_STATION]
	) f
WHERE [DIFF_OPERATION_PERIOD_FROM] <> 0
	OR [DIFF_OPERATION_PERIOD_TO] <> 0
	OR [DIFF_OPERATION_WEEKDAY_LIST] <> 0
	OR [DIFF_STD_LT] <> 0
	OR [DIFF_STA_LT] <> 0
