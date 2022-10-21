CREATE VIEW [dbo].[V_DIM_TIME_RANGE] 
--========================================================
--Created: ...                     Altered: 14-Sep-2020
--========================================================
--Thus view is no longer used in CUBE = [SCHEDULE_ANALYSIS]
--because to run it you need MAXRECURSION-clause, 
--but DSV does NOT allow this clause. To work around this problem
--Use function = [dbo].[F_D_TimeRange]() instead

--=======================================================
AS

select * from  [dbo].[FT_TIME_RANGE]()



