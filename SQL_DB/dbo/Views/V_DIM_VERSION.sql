



CREATE view [dbo].[V_DIM_VERSION] as (
select VERSION = N'BDG' ,VERSION_TYPE = N'Simple' , FORMULA = NULL
  UNION 
select  VERSION =N'FCST',VERSION_TYPE = N'Simple' , FORMULA = NULL  
  UNION 
select  VERSION =N'MIX FCST ACT', VERSION_TYPE = N'Simple' ,FORMULA = NULL
  UNION 
select  VERSION =N'ACT', VERSION_TYPE = N'Simple' ,FORMULA = NULL
 UNION 
select  VERSION =N'MIX vs BDG (+/-)', VERSION_TYPE = N'Calculated' ,FORMULA = N'[MIX FCST ACT] - [BDG]'  
 UNION 
select  VERSION =N'MIX vs BDG ( % )' ,VERSION_TYPE = N'Calculated' ,FORMULA = N'([MIX FCST ACT] / [BDG]) -1' 
)


 




