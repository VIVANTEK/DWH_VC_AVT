CREATE TABLE [dbo].[WRB_SET_FLEET] (
    [CONSUMPTION_CHARTER_0]       INT            NULL,
    [CONSUMPTION_DOMESTIC_1]      INT            NULL,
    [CONSUMPTION_INTERNATIONAL_2] INT            NULL,
    [WEIGHT_CAPACITY_3]           INT            NULL,
    [MTOW_4]                      INT            NULL,
    [MONTH_ID_5]                  INT            NULL,
    [TRANSPORT_CODE_6]            NVARCHAR (255) NULL,
    [MS_AUDIT_TIME_7]             DATETIME       NULL,
    [MS_AUDIT_USER_8]             NVARCHAR (255) NULL
);


GO


CREATE TRIGGER [dbo].[TR_SET_FLEET_AFTER_INSERT] ON [dbo].[WRB_SET_FLEET]
AFTER INSERT NOT FOR REPLICATION 
AS
 BEGIN
	EXEC [dbo].[P_UPDATE_FCT_SET_FLEET];
END


