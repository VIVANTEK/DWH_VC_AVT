﻿CREATE TABLE [dbo].[DIM_FLIGHT] (
    [AIRLINE]          NVARCHAR (255) NULL,
    [FLT_NUM]          NVARCHAR (255) NULL,
    [ORIG]             NVARCHAR (255) NULL,
    [DSTN]             NVARCHAR (255) NULL,
    [FLT_DESC]         NVARCHAR (255) NULL,
    [HAUL]             NVARCHAR (255) NULL,
    [FLT_TYPE_INT_DOM] NVARCHAR (255) NULL,
    [FLT_TYPE_SCH_CHR] NVARCHAR (255) NULL,
    [FLT_TYPE_PSN_CAR] NVARCHAR (255) NULL,
    [FLT_TYPE_OWH_OAL] NVARCHAR (255) NULL,
    [COUNTRY_TURNOVER] NVARCHAR (255) NULL,
    [DEST_GROUP]       NVARCHAR (255) NULL,
    [LOAD_TIME]        SMALLDATETIME  CONSTRAINT [DF_DIM_FLIGHT_LOAD_TIME] DEFAULT (getdate()) NULL,
    [LOAD_DATE]        AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);
