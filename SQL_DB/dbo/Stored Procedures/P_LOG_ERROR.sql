CREATE PROCEDURE [dbo].[P_LOG_ERROR]
(@ERR_DESC      nvarchar(1000)
,@SOURCE_OBJECT nvarchar(255)
,@SOURCE_USER   nvarchar(255) = NULL)
--=================================================
--Created: 21-Jul-2022        Altered: 21-Jul-2022  
--=================================================
--Used in procedure to log error
 
/*
--Run this view this way
DECLARE @ERR_DESC nvarchar(255) = N'TestError'
       ,@SOURCE_OBJECT nvarchar(255) = N'TestObject'
       ,@SOURCE_USER   nvarchar(255) = NULL; -- N'1PLUS1\p.dobrokhotov'
EXEC [dbo].[pLogError] @ERR_DESC, @SOURCE_OBJECT, @SOURCE_USER
---------------------------------------------------
SELECT * FROM [dbo].[LOG_ERROR]
--TRUNCATE TABLE [dbo].[LOG_ERROR]
*/
--=================================================
AS
BEGIN

   IF @SOURCE_USER IS NULL SET @SOURCE_USER = USER_NAME();
   INSERT INTO [dbo].[LOG_ERROR]
          (ERR_DESC, SOURCE_OBJECT, SOURCE_USER, LOG_TIME)
   VALUES (@ERR_DESC,@SOURCE_OBJECT,@SOURCE_USER, GetDate() );

END
