CREATE TABLE [dbo].[PBL_SET_FLAG_FLIGHT_PNL_ITEM] (
    [FLT_DESC]             NVARCHAR (255) NULL,
    [ITEM]                 NVARCHAR (255) NULL,
    [FLAG_FLIGHT_PNL_ITEM] INT            NULL,
    [LOAD_TIME]            DATETIME       NULL,
    [LOAD_DATE]            AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);

