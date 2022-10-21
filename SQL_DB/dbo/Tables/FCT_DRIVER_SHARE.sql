CREATE TABLE [dbo].[FCT_DRIVER_SHARE] (
    [PNL_ITEM]                NVARCHAR (17) NOT NULL,
    [FLIGHT]                  NVARCHAR (15) NOT NULL,
    [MONTH_ID]                INT           NOT NULL,
    [VERSION]                 NVARCHAR (4)  NOT NULL,
    [FLAG_USE_FLIGHT]         INT           NULL,
    [AMOUNT_FOR_ALLOCATION]   INT           NULL,
    [DRIVER_FOR_ALLOCATION]   INT           NULL,
    [DRIVER_USE_FLIGHT]       INT           NULL,
    [DRIVER_USE_FLIGHT_TOTAL] INT           NULL,
    [SHARE_AMOUNT]            INT           NULL,
    [AMOUNT_ALLOCATED]        INT           NULL,
    [ROW_ID]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_FCT_DRIVER_SHARE] PRIMARY KEY CLUSTERED ([ROW_ID] ASC)
);


GO
--The code below is a template for creating trigger. It's the same for all tables except the name of table and trigger
CREATE TRIGGER TR_FCT_DRIVER_SHARE ON [dbo].[FCT_DRIVER_SHARE] FOR INSERT, UPDATE, DELETE 
AS  
DECLARE @TableName  varchar(255) ;
--Get the name of the current table where trigger is launched
--@@PROCID	returns the name of currect object (in this case it is trigger name, by which we find table name
SELECT  @TableName = object_name(parent_id) FROM  sys.triggers where object_id = @@PROCID	
--Save data from trigger system-tables(that can be seen in trigger ONLY) into temp tables to be used in procedure later
SELECT * INTO #ins FROM inserted ; SELECT * INTO #del FROM deleted ;
--Run procedure that logs data for the given table. This procedure uses table #ins and #del created above
EXEC [dbo].[P_AUDIT] @TableName ; 