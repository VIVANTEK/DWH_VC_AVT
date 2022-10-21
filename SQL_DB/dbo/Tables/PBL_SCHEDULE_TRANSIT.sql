CREATE TABLE [dbo].[PBL_SCHEDULE_TRANSIT] (
    [LAYER_ID]         NVARCHAR (255) NULL,
    [VERSION]          NVARCHAR (255) NULL,
    [PATH_KEY]         NVARCHAR (255) NULL,
    [RNG_ID]           NVARCHAR (255) NULL,
    [DATE]             NVARCHAR (255) NULL,
    [COUNT_CONNECTION] INT            NULL,
    [LOAD_TIME]        DATETIME       NULL,
    [LOAD_DATE]        AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);

