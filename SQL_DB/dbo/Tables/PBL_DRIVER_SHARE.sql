CREATE TABLE [dbo].[PBL_DRIVER_SHARE] (
    [VERSION]                 NVARCHAR (255) NULL,
    [ITEM]                    NVARCHAR (255) NULL,
    [FLT_DESC]                NVARCHAR (255) NULL,
    [MONTH_ID]                NVARCHAR (255) NULL,
    [AMOUNT_FOR_ALLOCATION]   FLOAT (53)     NULL,
    [DRIVER_FOR_ALLOCATION]   FLOAT (53)     NULL,
    [DRIVER_USE_FLIGHT]       FLOAT (53)     NULL,
    [DRIVER_USE_FLIGHT_TOTAL] FLOAT (53)     NULL,
    [FLAG_USE_FLIGHT]         FLOAT (53)     NULL,
    [SHARE_AMOUNT]            FLOAT (53)     NULL,
    [LOAD_TIME]               DATETIME       CONSTRAINT [DF_PBL_DRIVER_SHARE_LOAD_DATE] DEFAULT (getdate()) NULL,
    [LOAD_DATE]               AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);

