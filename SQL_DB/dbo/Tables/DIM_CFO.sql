CREATE TABLE [dbo].[DIM_CFO] (
    [CFO_ID]          INT            IDENTITY (1, 1) NOT NULL,
    [CFO_NAME]        NVARCHAR (255) NULL,
    [CFO_PARENT_NAME] NVARCHAR (255) NULL,
    [CFO_TYPE]        NVARCHAR (255) NULL,
    [LOAD_TIME]       SMALLDATETIME  NULL,
    [LOAD_DATE]       AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);

