﻿CREATE TABLE [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM] (
    [FLAG_FLIGHT_PNL_ITEM_0] INT            NULL,
    [ITEM_1]                 NVARCHAR (255) NULL,
    [FLT_DESC_2]             NVARCHAR (255) NULL,
    [MS_AUDIT_TIME_3]        DATETIME       NULL,
    [MS_AUDIT_USER_4]        NVARCHAR (255) NULL
);


GO

 
 
CREATE TRIGGER [dbo].[TR_WRB_SET_FLAG_FLIGHT_PNL_ITEM_AFTER_INSERT] ON [dbo].[WRB_SET_FLAG_FLIGHT_PNL_ITEM]
AFTER INSERT NOT FOR REPLICATION 
AS
 BEGIN
	EXEC [dbo].[P_UPDATE_FCT_SET_FLAG_FLIGHT_PNL_ITEM] ;
END

