CREATE TABLE [dbo].[PBL_SET_FLEET] (
    [MONTH_ID]                  NVARCHAR (255) NULL,
    [TRANSPORT_CODE]            NVARCHAR (255) NULL,
    [CONSUMPTION_CHARTER]       FLOAT (53)     NULL,
    [CONSUMPTION_DOMESTIC]      FLOAT (53)     NULL,
    [CONSUMPTION_INTERNATIONAL] FLOAT (53)     NULL,
    [MTOW]                      FLOAT (53)     NULL,
    [WEIGHT_CAPACITY]           FLOAT (53)     NULL,
    [LOAD_TIME]                 DATETIME       NULL,
    [LOAD_DATE]                 AS             (CONVERT([date],[LOAD_TIME])) PERSISTED
);

