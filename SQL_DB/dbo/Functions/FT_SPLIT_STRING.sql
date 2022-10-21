
CREATE FUNCTION [dbo].[FT_SPLIT_STRING]
(@List VARCHAR(8000) = NULL, @Pattern VARCHAR(50) ) 
RETURNS TABLE WITH SCHEMABINDING 
--=========================================================================================
--Created: 04-Dec-2020                                                 Altered: 04-Dec-2020  
--=========================================================================================
--Splits string by pattern that is used supported by LIKE or PATINDEX  clause  
/*
DECLARE @String  VARCHAR(8000),   @Pattern VARCHAR(50)
SELECT  @String = 'A100B200C300', @Pattern = '[0-9]' 
SELECT * FROM [dbo].[FT_SPLIT_STRING](@String,@Pattern) WHERE Matched = 1
--=========================================================================================
*/


AS 
RETURN
    WITH numbers 
	AS
	 (SELECT TOP(ISNULL(DATALENGTH(@List), 0))
              n = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
      FROM
      (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) d (n),
      (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) e (n),
      (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) f (n),
      (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) g (n) )
 --========================================================================================
    SELECT
      ItemNumber = ROW_NUMBER() OVER(ORDER BY MIN(n)),
      Item = SUBSTRING(@List,MIN(n),1+MAX(n)-MIN(n)),
      [Matched]
     FROM 
	   (SELECT n, y.[Matched], Grouper = n - ROW_NUMBER() OVER(ORDER BY y.[Matched],n)
        FROM numbers
        CROSS APPLY ( select [Matched] = case when SUBSTRING(@List,n,1) LIKE @Pattern then 1 else 0 end) y
       ) d
     GROUP BY [Matched], Grouper



