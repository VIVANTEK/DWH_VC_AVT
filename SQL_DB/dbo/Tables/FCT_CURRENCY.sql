CREATE TABLE [dbo].[FCT_CURRENCY] (
    [DIGITAL_CODE]  INT            NOT NULL,
    [MONTH_ID]      INT            NOT NULL,
    [VERSION]       NVARCHAR (255) NOT NULL,
    [CURRENCY_RATE] FLOAT (53)     NULL,
    [ROW_ID]        BIGINT         IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_FCT_CURRENCY] PRIMARY KEY CLUSTERED ([ROW_ID] ASC)
);


GO
CREATE TRIGGER TR_FCT_CURRENCY ON [dbo].[FCT_CURRENCY] FOR INSERT, UPDATE, DELETE 
AS  
DECLARE @TableName  varchar(255) ;
--Get the name of the current table where trigger is launched
--@@PROCID	returns the name of currect object (in this case it is trigger name, by which we find table name
SELECT  @TableName = object_name(parent_id) FROM  sys.triggers where object_id = @@PROCID	
--Save data from trigger system-tables(that can be seen in trigger ONLY) into temp tables to be used in procedure later
SELECT * INTO #ins FROM inserted ; SELECT * INTO #del FROM deleted ;
--Run procedure that logs data for the given table. This procedure uses table #ins and #del created above
EXEC [dbo].[P_AUDIT] @TableName ; 
