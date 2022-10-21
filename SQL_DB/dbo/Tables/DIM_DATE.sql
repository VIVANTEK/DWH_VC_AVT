CREATE TABLE [dbo].[DIM_DATE] (
    [DATE_ID]      INT            NULL,
    [DATE_DESC]    NVARCHAR (255) NULL,
    [DOW_ID]       INT            NULL,
    [DOW_DESC]     NVARCHAR (255) NULL,
    [WEEK_ID]      INT            NULL,
    [WEEK_DESC]    NVARCHAR (255) NULL,
    [MONTH_ID]     INT            NULL,
    [MONTH_DESC]   NVARCHAR (255) NULL,
    [QUARTER_ID]   INT            NULL,
    [QUARTER_DESC] NVARCHAR (255) NULL,
    [YEAR_ID]      INT            NULL,
    [LOAD_TIME]    SMALLDATETIME  CONSTRAINT [DF_DIM_DATE_LOAD_TIME] DEFAULT (getdate()) NULL,
    [LOAD_DATE]    AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);

