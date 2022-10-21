CREATE TABLE [dbo].[FCT_CFO] (
    [PNL_ITEM]   VARCHAR (255) NOT NULL,
    [CFO_NAME]   VARCHAR (255) NOT NULL,
    [MONTH_ID]   INT           NOT NULL,
    [VERSION]    VARCHAR (255) NOT NULL,
    [LAYER_ID]   AS            ((0)),
    [PNL_AMOUNT] INT           NULL,
    [ROW_ID]     BIGINT        IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_FCT_CFO_1] PRIMARY KEY CLUSTERED ([ROW_ID] ASC)
);


GO
--  select * from [dbo].[AUDIT] 
CREATE TRIGGER [dbo].[TR_FCT_CFO] ON [dbo].[FCT_CFO] FOR INSERT, UPDATE, DELETE 
AS  
DECLARE @TableName  varchar(255) , @ActionType char(1)
--Get the name of the current table where trigger is launched
--@@PROCID	returns the name of currect object (in thi case it is trigger name, by which we find table name
SELECT  @TableName = object_name(parent_id) FROM  sys.triggers where object_id = @@PROCID	
--Save data from trigger system-tables(that can be seen in trigger ONLY) into temp tables to be used in procedure later
SELECT * INTO #ins FROM inserted ; SELECT * INTO #del FROM deleted ;
--Run procedure that logs data for the given table. This procedure uses table #ins and #del created above
EXEC [dbo].[P_AUDIT] @TableName ;  
