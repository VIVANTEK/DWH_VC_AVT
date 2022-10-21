
/*
select * from [dbo].[PL_HIERARCHY] where HIERARCHY_TYPE = 1 AND GL_ACC = N'Внутрикорпоративные расходы с Систерз'
select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM](1,NULL, default,1) where GL_NAME = N'Внутрикорпоративные расходы с Систерз'
---------------------------------------------------------------------------------------------
select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (2,'', default,default) -- all levels 
select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (2,'0', default,default) -- all levels 
select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (2,N'Валовый доход от рекламы', default,default) -- all levels 
*/
CREATE FUNCTION [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] 
(@HierachyType int = NULL, @ParentItemID nvarchar(255)  = NULL, @Level int = 1000 , @IsLeaf bit = NULL)
--=========================================================================================
-- Created: 01-Aug-2022                                               Altered: 01-Aug-2022             
--=========================================================================================
-- You can use this function to view a list of child items 
-- in PL-hierachy for a given Parent Item
--=========================================================================================
-- Example:
/*
 exec sp_recompile '[dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM]'
-------------------------------------------------------------------------------------------
 select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (1,N'Pasengers by cabin', default,default) -- all levels 
 select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (1,N'Pasengers by cabin', default,1)       -- lowest level
 select * from [dbo].[FT_PL_ALL_LEV_HIERARCHY_BY_PARENT_ITEM] (1,N'Pasengers by cabin', default,0) -- all levels except lowest
 ------------------------------------------------------------------------------------------
 select * from [dbo].[DIM_PROFIT_LOSS] where [PARENT_ITEM] = N'Pasengers by cabin' and HIERARCHY_TYPE = 1 
 select * from [dbo].[DIM_PROFIT_LOSS] where [ITEM] = N'Pasengers by cabin' and HIERARCHY_TYPE = 1 
 select * from [dbo].[DIM_PROFIT_LOSS] where PARENT_ITEM IS NULL


--==========================================================================================
*/
RETURNS TABLE
AS
RETURN  
(
    --=====================================================================================================
    --DECLARE @HierachyType int =1,  @ParentItemID int = 606, @Level int = 1000, @IsLeaf bit = NULL;
    --=====================================================================================================
    WITH PL_DIC
	AS
	(SELECT [ITEM_ID],[ITEM],[PARENT_ITEM],[ITEM_TYPE]
           ,[HIERARCHY_TYPE],[UNARY_OPERATOR],[FORMULA]
           ,[LOAD_TIME],[LOAD_DATE]
           ,[IS_LEAF] = (select case  count(*) when 0 then 1 else 0 end from [dbo].[DIM_PROFIT_LOSS] where [PARENT_ITEM] = T.[ITEM])
       FROM [DWH_VC_AVT].[dbo].[DIM_PROFIT_LOSS] AS T 
	)
    --=====================================================================================================
    ,BomTree  
    AS 
    (
	  -- Anchor, or data for which to run a recursive query based on Comman Table Expression (CTE)
      SELECT [ITEM] = P.[ITEM]
	        ,[PARENT_ITEM] = P.[PARENT_ITEM]
	        ,[LEVEL] = 1
	        ,P.[IS_LEAF]--,P.[IS_SHOW_VALUE],P.[OPER_SIGN]	
			,P.[HIERARCHY_TYPE]	
			,P.[UNARY_OPERATOR]
      FROM  PL_DIC AS P 
	  WHERE (CAST(P.[ITEM] as nvarchar(255)) = @ParentItemID 
	         OR P.[PARENT_ITEM]  = @ParentItemID 
	         OR LTRIM(RTRIM(ISNULL(@ParentItemID,''))) IN (N'',N'0',N'All') )
	  AND (P.[HIERARCHY_TYPE] = @HierachyType OR @HierachyType IS NULL)

     UNION ALL

    -- Recursive call of component articles based on an Anchor that stores the parent item
      SELECT [ITEM] = C.[ITEM]
	        ,[PARENT_ITEM] = C.[PARENT_ITEM]
	        ,[LEVEL] = [LEVEL] + 1
	        ,C.[IS_LEAF]--,C.[IS_SHOW_VALUE],C.[OPER_SIGN]	
			,C.[HIERARCHY_TYPE]	
			,C.[UNARY_OPERATOR]
      FROM  PL_DIC AS C   
      INNER JOIN BomTree BT ON C.[PARENT_ITEM] = BT.[ITEM]
      WHERE [LEVEL]+1 <= ISNULL(@Level,1000)
	    AND (C.[HIERARCHY_TYPE]	= @HierachyType OR @HierachyType IS NULL)
    ) --select * from BomTree

  --Here we group rows for any case, cause if @ParentItemID = NULL (i.e. was NOT passed)
  --then the same PL-item (GL_NAME) can repaet several times with different [LEVEL], 
  --but we need only one with the 1st LEVEL
    SELECT [PARAM_ID] = @ParentItemID  
	      ,[ITEM],[PARENT_ITEM] 
		  ,[LEVEL] =  MIN([LEVEL])
		--,[IS_LEAF],[IS_SHOW_VALUE],[OPER_SIGN]
          ,[HIERARCHY_TYPE],[UNARY_OPERATOR]
    FROM BomTree WHERE ([IS_LEAF] = @IsLeaf OR @IsLeaf IS NULL)
    GROUP BY [ITEM],[PARENT_ITEM],[IS_LEAF]--,[IS_SHOW_VALUE],[OPER_SIGN]
            ,[HIERARCHY_TYPE],[UNARY_OPERATOR]

)


