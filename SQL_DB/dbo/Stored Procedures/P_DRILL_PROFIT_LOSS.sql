
CREATE  PROCEDURE [dbo].[P_DRILL_PROFIT_LOSS]
( @pVERSION         as nvarchar(255) = N'All'  -- = key  
 ------------------ PROFIT_LOSS ----------------------------
 ,@pPNL_ITEM        as nvarchar(255) = N'All'  -- = key   
 ,@pPNL_ITEM_HRCH   as nvarchar(255) = N'All'  -- =   
 ,@pHIERARCHY_TYPE  as nvarchar(255) = N'All'  -- =  
 ----------------- FLIGHT ----------------------------------
 ,@pFLIGHT           as nvarchar(255) = N'All'  -- = key  
 ,@pAIRLINE          as nvarchar(255) = N'All'
 ,@pCOUNTRY_TURNOVER as nvarchar(255) = N'All'
 ,@pDEST_GROUP       as nvarchar(255) = N'All'
 ,@pDSTN             as nvarchar(255) = N'All'
 ,@pFLT_NUM          as nvarchar(255) = N'All'
 ,@pFLT_TYPE_INT_DOM as nvarchar(255) = N'All'
 ,@pFLT_TYPE_OWH_OAL as nvarchar(255) = N'All'
 ,@pFLT_TYPE_PSN_CAR as nvarchar(255) = N'All'
 ,@pFLT_TYPE_SCH_CHR as nvarchar(255) = N'All'
 ,@pHAUL             as nvarchar(255) = N'All'
 ,@pORIG             as nvarchar(255) = N'All'
 ,@pFLIGHT_HRCH      as nvarchar(255) = N'All' 
------------------- MONTH ----------------------------------
 ,@pMONTH_ID         as nvarchar(255) = N'All'  -- = key (YYYYMM)  
 ,@pQUARTER_ID       as nvarchar(255) = N'All'
 ,@pYEAR_ID          as nvarchar(255) = N'All'
 ,@pMONTH_HRCH       as nvarchar(255) = N'All'
 ) 
--====================================================================================== 
--Created: 01-Aug-2022                                              Altered: 01-Aug-2022  
--====================================================================================== 
--This view is used as a sources for drill-down report in cube ProfitLoss

--***************************************************************************************
/*
-- exec sp_recompile '[dbo].[P_Drill_ProfitLoss]'
--=======================================================================================

----------------------------------------------------------------------------------------- 
select * from [dbo].[LOG_PROFIT_LOSS]
*/
--====================================================================================== 
--WITH RECOMPILE --This line can be commented because compiling can take too long 
AS
BEGIN
  SELECT @pVERSION          = LTRIM(RTRIM(ISNULL(@pVERSION,          N''))) 
         ---------------------------------------------------------------
        ,@pPNL_ITEM         = LTRIM(RTRIM(ISNULL(@pPNL_ITEM,         N''))) 
        ,@pPNL_ITEM_HRCH    = LTRIM(RTRIM(ISNULL(@pPNL_ITEM_HRCH,    N''))) 
        ,@pHIERARCHY_TYPE   = LTRIM(RTRIM(ISNULL(@pHIERARCHY_TYPE,   N''))) 
         ---------------------------------------------------------------		 		 
        ,@pFLIGHT           = LTRIM(RTRIM(ISNULL(@pFLIGHT,           N'')))  
        ,@pAIRLINE          = LTRIM(RTRIM(ISNULL(@pAIRLINE,          N'')))  
        ,@pCOUNTRY_TURNOVER = LTRIM(RTRIM(ISNULL(@pCOUNTRY_TURNOVER, N'')))  
        ,@pDEST_GROUP       = LTRIM(RTRIM(ISNULL(@pDEST_GROUP,       N'')))  
        ,@pDSTN             = LTRIM(RTRIM(ISNULL(@pDSTN,             N'')))  
        ,@pFLT_NUM          = LTRIM(RTRIM(ISNULL(@pFLT_NUM,          N'')))  
        ,@pFLT_TYPE_INT_DOM = LTRIM(RTRIM(ISNULL(@pFLT_TYPE_INT_DOM, N'')))  
        ,@pFLT_TYPE_OWH_OAL = LTRIM(RTRIM(ISNULL(@pFLT_TYPE_OWH_OAL, N'')))  
        ,@pFLT_TYPE_PSN_CAR = LTRIM(RTRIM(ISNULL(@pFLT_TYPE_PSN_CAR, N'')))  
        ,@pFLT_TYPE_SCH_CHR = LTRIM(RTRIM(ISNULL(@pFLT_TYPE_SCH_CHR, N'')))  
        ,@pHAUL             = LTRIM(RTRIM(ISNULL(@pHAUL,             N'')))  
        ,@pORIG             = LTRIM(RTRIM(ISNULL(@pORIG,             N'')))  
        ,@pFLIGHT_HRCH      = LTRIM(RTRIM(ISNULL(@pFLIGHT_HRCH,      N'')))  -----------!!!!!!!!!!!!-------------------
         ---------------------------------------------------------------
        ,@pMONTH_ID         = LTRIM(RTRIM(ISNULL(@pMONTH_ID,         N''))) 
        ,@pQUARTER_ID       = LTRIM(RTRIM(ISNULL(@pQUARTER_ID,       N''))) 
        ,@pYEAR_ID          = LTRIM(RTRIM(ISNULL(@pYEAR_ID,          N''))) 
        ,@pMONTH_HRCH       = LTRIM(RTRIM(ISNULL(@pMONTH_HRCH,       N''))) ;	
  --==================================================================== 	
  IF @pVERSION          IN(N'All',N'',N'0')  SET @pVERSION          = NULL;  
  ----------------------------------------------------------------------
  IF @pPNL_ITEM         IN(N'All',N'',N'0')  SET @pPNL_ITEM         = NULL;
  IF @pPNL_ITEM_HRCH  IN(N'All',N'',N'0')    SET @pPNL_ITEM_HRCH  = NULL;
  IF @pHIERARCHY_TYPE   IN(N'All',N'',N'0')  SET @pHIERARCHY_TYPE   = NULL;
  ----------------------------------------------------------------------
  IF @pFLIGHT           IN(N'All',N'',N'0')  SET @pFLIGHT           = NULL;
  IF @pAIRLINE          IN(N'All',N'',N'0')  SET @pAIRLINE          = NULL;
  IF @pCOUNTRY_TURNOVER IN(N'All',N'',N'0')  SET @pCOUNTRY_TURNOVER = NULL;
  IF @pDEST_GROUP       IN(N'All',N'',N'0')  SET @pDEST_GROUP       = NULL;
  IF @pDSTN             IN(N'All',N'',N'0')  SET @pDSTN             = NULL;
  IF @pFLT_NUM          IN(N'All',N'',N'0')  SET @pFLT_NUM          = NULL;
  IF @pFLT_TYPE_INT_DOM IN(N'All',N'',N'0')  SET @pFLT_TYPE_INT_DOM = NULL;
  IF @pFLT_TYPE_OWH_OAL IN(N'All',N'',N'0')  SET @pFLT_TYPE_OWH_OAL = NULL;
  IF @pFLT_TYPE_PSN_CAR IN(N'All',N'',N'0')  SET @pFLT_TYPE_PSN_CAR = NULL;
  IF @pFLT_TYPE_SCH_CHR IN(N'All',N'',N'0')  SET @pFLT_TYPE_SCH_CHR = NULL;
  IF @pHAUL             IN(N'All',N'',N'0')  SET @pHAUL             = NULL;
  IF @pORIG             IN(N'All',N'',N'0')  SET @pORIG             = NULL;
  IF @pFLIGHT_HRCH      IN(N'All',N'',N'0')  SET @pFLIGHT_HRCH      = NULL; 
  ----------------------------------------------------------------------
  IF @pMONTH_ID        IN(N'All',N'',N'0')  SET @pMONTH_ID         = NULL;
  IF @pYEAR_ID         IN(N'All',N'',N'0')  SET @pYEAR_ID          = NULL;
  IF @pQUARTER_ID      IN(N'All',N'',N'0')  SET @pQUARTER_ID       = NULL;
  ----------------------------------------------------------------------
  --IF  @pMONTH_HRCH  IN(N'All',N'',N'0')     SET @pMONTH_HRCH       = NULL;
  --IF  @pYEAR_ID  IS NULL AND LEN(ISNULL(@pMONTH_HRCH,'')) >=4  SET @pYEAR_ID  = LEFT(@pMONTH_HRCH,4);
  --IF  @pYEAR_ID  IS NULL AND LEN(ISNULL(@pMONTH_ID,''))   >=4  SET @pYEAR_ID  = LEFT(@pMONTH_ID,4);
  --=@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --Because we cannot trust values in colomn IS_LEAF in PL-dictionary table = dbo.PL_HIERARCHY
  --that is used in table-function below, but we MUST pass correct value for its @IsLeaf param into function below
  --FUNCTION [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (@HierachyType int = NULL, @ParentItemID nvarchar(255)  = NULL, @Level int = 1000 , @IsLeaf bit = NULL)
  --we have to calculate this value here, based on the info whether passed in PL-item(@pPL_NAME) has a parent code
  DECLARE @IsLeaf bit; 
  SELECT @IsLeaf = (select top 1 IsLeaf = CASE WHEN ISNULL([PARENT_ITEM],'0') = '0' THEN NULL ELSE 1 END
                    from [dbo].[DIM_PROFIT_LOSS] where [ITEM] = @pPNL_ITEM_HRCH and [HIERARCHY_TYPE] = @pHIERARCHY_TYPE);
  --select  IsLeaf = @IsLeaf 

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
  --Get a general list of all lower-level articles from the PL-items from PL-dictionary
  --The code for this was moved to a separate function that  "does its job well" but it's large 
  --enough to take it into this procedure not "clutter up" the code of this procedure
  --select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (1,N'Pasengers by cabin', default,1)       -- lowest level
  WITH PL_LIST AS 
  (SELECT [PNL_ITEM] = [PARENT_ITEM],[ITEM]  
   FROM [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM](@pHIERARCHY_TYPE,@pPNL_ITEM_HRCH,default,@IsLeaf)   
  )  -- select * from PL_LIST
    --   PNL_ITEM	            ITEM
       --Pasengers by cabin	    PAX Y+

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
  -- Get list of periods (Now I don’t use this CTE anymore, but I left it just in case)
  ,CLNDR AS 
  (SELECT DISTINCT [YEAR_ID],[QUARTER_ID],[MONTH_ID] FROM  [dbo].[DIM_DATE] 
   WHERE ([YEAR_ID]  = CAST(@pYEAR_ID  as int)  OR @pYEAR_ID  IS NULL)  
     AND ([MONTH_ID] = CAST(@pMONTH_ID as int)  OR @pMONTH_ID IS NULL)                    
     AND ([QUARTER_ID]   = CAST(@pQUARTER_ID as int) OR @pQUARTER_ID IS NULL)						
  ) -- select * , pYEAR_ID =  @pYEAR_ID ,pQUARTER_ID = @pQUARTER_ID, pMONTH_ID =  @pMONTH_ID   from CLNDR

  --=@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ,RESULT AS   
  (SELECT FCT.[PNL_ITEM],ITM.[PARENT_ITEM],ITM.[ITEM_TYPE],ITM.[HIERARCHY_TYPE]--,ITM.[ITEM_ID],ITM.[UNARY_OPERATOR]
         ----------------------------------------------------------------------------------------------
         ,FCT.[FLIGHT],FLT.[AIRLINE],FLT.[FLT_NUM],FLT.[ORIG],FLT.[DSTN],FLT.[HAUL]
         ,FLT.[FLT_TYPE_INT_DOM],FLT.[FLT_TYPE_SCH_CHR],FLT.[FLT_TYPE_PSN_CAR]
         ,FLT.[FLT_TYPE_OWH_OAL],FLT.[COUNTRY_TURNOVER],FLT.[DEST_GROUP]
         ----------------------------------------------------------------------------------------------
         ,FCT.[MONTH_ID],CLD.[MONTH_DESC],CLD.[QUARTER_ID],CLD.[QUARTER_DESC],CLD.[YEAR_ID]
	     ----------------------------------------------------------------------------------------------
         ,FCT.[VERSION],VER.[VERSION_TYPE] --, VER.[FORMULA],FCT.[PNL_AMOUNT]
         ----------------------------------------------------------------------------------------------
         ,L0G.[OLD_VALUE],L0G.[NEW_VALUE],L0G.[LOG_TIME],L0G.[LOG_USER]
   FROM [dbo].[FCT_PROFIT_LOSS] AS FCT
   INNER JOIN
             (SELECT [MONTH_ID], [MONTH_DESC], [QUARTER_ID], [QUARTER_DESC], [YEAR_ID]
              FROM [dbo].[DIM_DATE] WHERE (LEFT([DATE_DESC], 2) = '01') 
             ) AS CLD
   ON FCT.[MONTH_ID] = CLD.[MONTH_ID]
   INNER JOIN [dbo].[DIM_FLIGHT]      AS FLT ON FCT.[FLIGHT] = FLT.[FLT_DESC]
   INNER JOIN [dbo].[V_DIM_VERSION]   AS VER ON FCT.[VERSION] = VER.[VERSION]
   INNER JOIN [dbo].[DIM_PROFIT_LOSS] AS ITM ON FCT.[PNL_ITEM] = ITM.[ITEM]
--------------------------------------------------------------------------------
   INNER JOIN [dbo].[LOG_PROFIT_LOSS] AS L0G 
   ON  FCT.[PNL_ITEM] = L0G.[PNL_ITEM] AND FCT.[FLIGHT]  = L0G.[FLIGHT] 
   AND FCT.[MONTH_ID] = L0G.[MONTH_ID] AND FCT.[VERSION] = L0G.[VERSION] 
   GROUP BY FCT.[PNL_ITEM],ITM.[PARENT_ITEM],ITM.[ITEM_TYPE],ITM.[HIERARCHY_TYPE]
           ,FCT.[FLIGHT],FLT.[AIRLINE],FLT.[FLT_NUM],FLT.[ORIG],FLT.[DSTN],FLT.[HAUL]
           ,FLT.[FLT_TYPE_INT_DOM],FLT.[FLT_TYPE_SCH_CHR],FLT.[FLT_TYPE_PSN_CAR]
           ,FLT.[FLT_TYPE_OWH_OAL],FLT.[COUNTRY_TURNOVER],FLT.[DEST_GROUP]
           ,FCT.[MONTH_ID],CLD.[MONTH_DESC],CLD.[QUARTER_ID],CLD.[QUARTER_DESC],CLD.[YEAR_ID]
           ,FCT.[VERSION],VER.[VERSION_TYPE]
           ,L0G.[OLD_VALUE],L0G.[NEW_VALUE],L0G.[LOG_TIME],L0G.[LOG_USER]
  ) --select * from RESULT  --select * from [dbo].[LOG_PROFIT_LOSS]
  
   SELECT TOP 50000  
         T1.[PARENT_ITEM], T1.[PNL_ITEM]
        ,T1.[FLIGHT]
        ,T1.[MONTH_ID]
        ,T1.[VERSION]
        ,T1.[OLD_VALUE]
        ,T1.[NEW_VALUE]
        ,T1.[LOG_TIME]
        ,T1.[LOG_USER]
  FROM RESULT AS T1 
     INNER JOIN PL_LIST AS T2 ON  T1.[PNL_ITEM] = T2.[ITEM] 	  
     INNER JOIN CLNDR   AS T3 ON T1.[MONTH_ID]    = T3.[MONTH_ID]
  WHERE (T1.[VERSION]           = @pVERSION          OR @pVERSION          IS NULL)
    AND (T1.[HIERARCHY_TYPE]    = @pHIERARCHY_TYPE   OR @pHIERARCHY_TYPE   IS NULL)
    AND (T1.[FLIGHT]            = @pFLIGHT           OR @pFLIGHT           IS NULL)
    AND (T1.[AIRLINE]           = @pAIRLINE          OR @pAIRLINE          IS NULL)
    AND (T1.[COUNTRY_TURNOVER]  = @pCOUNTRY_TURNOVER OR @pCOUNTRY_TURNOVER IS NULL)
    AND (T1.[DEST_GROUP]        = @pDEST_GROUP       OR @pDEST_GROUP       IS NULL)
    AND (T1.[DSTN]              = @pDSTN             OR @pDSTN             IS NULL)
    AND (T1.[FLT_NUM]           = @pFLT_NUM          OR @pFLT_NUM          IS NULL)
    AND (T1.[FLT_TYPE_INT_DOM]  = @pFLT_TYPE_INT_DOM OR @pFLT_TYPE_INT_DOM IS NULL)
    AND (T1.[FLT_TYPE_OWH_OAL]  = @pFLT_TYPE_OWH_OAL OR @pFLT_TYPE_OWH_OAL IS NULL)
    AND (T1.[FLT_TYPE_PSN_CAR]  = @pFLT_TYPE_PSN_CAR OR @pFLT_TYPE_PSN_CAR IS NULL)
    AND (T1.[FLT_TYPE_SCH_CHR]  = @pFLT_TYPE_SCH_CHR OR @pFLT_TYPE_SCH_CHR IS NULL)
    AND (T1.[HAUL]              = @pHAUL             OR @pHAUL             IS NULL)
    AND (T1.[ORIG]              = @pORIG             OR @pORIG             IS NULL)
    AND (T1.[FLIGHT]            = @pFLIGHT_HRCH      OR @pFLIGHT_HRCH      IS NULL)
  ORDER BY T1.[PNL_ITEM],T1.[LOG_TIME] 
   --OPTION (FORCE ORDER) 
   --First filter smaller table and only after that JOIN it to larger table ...
   --Without this OPTION sql server prepares execution plan too long. See https://dba.stackexchange.com/questions/279409/building-an-execution-plan-takes-too-long-on-sql-server
   --OPTION FORCE ORDER specifies that the join order of the query should be preserved during query optimisation (as specified by MSDN),
   --this means in my case the query plan changed and generated the plan based on the smaller table, then joining to the larger tables,
   --massively reducing the query time and load.

END
/*
 SELECT
  pVERSION          = @pVERSION   
 ------------------ PROFIT_LOSS ----------------------------
 ,pPNL_ITEM         = @pPNL_ITEM         
 ,pPNL_ITEM_HRCH    = @pPNL_ITEM_HRCH   
 ,pHIERARCHY_TYPE   = @pHIERARCHY_TYPE  
 ----------------- FLIGHT ----------------------------------
 ,pFLIGHT           = @pFLIGHT            
 ,pAIRLINE          = @pAIRLINE           
 ,pCOUNTRY_TURNOVER = @pCOUNTRY_TURNOVER   
 ,pDEST_GROUP       = @pDEST_GROUP        
 ,pDSTN             = @pDSTN              
 ,pFLT_NUM          = @pFLT_NUM           
 ,pFLT_TYPE_INT_DOM = @pFLT_TYPE_INT_DOM  
 ,pFLT_TYPE_OWH_OAL = @pFLT_TYPE_OWH_OAL  
 ,pFLT_TYPE_PSN_CAR = @pFLT_TYPE_PSN_CAR  
 ,pFLT_TYPE_SCH_CHR = @pFLT_TYPE_SCH_CHR  
 ,pHAUL             = @pHAUL              
 ,pORIG             = @pORIG              
 ,pFLIGHT_HRCH      = @pFLIGHT_HRCH       
------------------- MONTH ----------------------------------
 ,pMONTH_ID         = @pMONTH_ID          
 ,pQUARTER_ID       = @pQUARTER_ID        
 ,pYEAR_ID          = @pYEAR_ID           
 ,pMONTH_HRCH       = @pMONTH_HRCH  
*/

