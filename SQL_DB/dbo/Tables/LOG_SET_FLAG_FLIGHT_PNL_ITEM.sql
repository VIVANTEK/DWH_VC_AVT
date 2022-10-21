﻿CREATE TABLE [dbo].[LOG_SET_FLAG_FLIGHT_PNL_ITEM] (
    [PNL_ITEM]  NVARCHAR (255) NULL,
    [FLIGHT]    NVARCHAR (255) NULL,
    [FLD_NAME]  AS             (N'FLAG_FLIGHT_PNL_ITEM') PERSISTED NOT NULL,
    [OLD_VALUE] INT            NULL,
    [NEW_VALUE] INT            NULL,
    [LOG_TIME]  SMALLDATETIME  NULL,
    [LOG_USER]  NVARCHAR (255) NULL
);
