CREATE TABLE [dbo].[LOG_SET_FLEET] (
    [TRANSPORT_CODE] NVARCHAR (255) NULL,
    [MONTH_ID]       INT            NULL,
    [FLD_NAME]       NVARCHAR (255) NULL,
    [OLD_VALUE]      FLOAT (53)     NULL,
    [NEW_VALUE]      FLOAT (53)     NULL,
    [LOG_TIME]       SMALLDATETIME  NULL,
    [LOG_USER]       NVARCHAR (255) NULL
);

