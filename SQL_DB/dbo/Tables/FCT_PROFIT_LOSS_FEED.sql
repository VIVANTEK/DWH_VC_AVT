﻿CREATE TABLE [dbo].[FCT_PROFIT_LOSS_FEED] (
    [PNL_ITEM]     NVARCHAR (255) NOT NULL,
    [FLIGHT]       NVARCHAR (255) NOT NULL,
    [MONTH_ID]     INT            NOT NULL,
    [VERSION]      NVARCHAR (255) NOT NULL,
    [PNL_AMOUNT]   SMALLMONEY     CONSTRAINT [DF_FCT_PROFIT_LOSS_FEED_PNL_AMOUNT] DEFAULT ((2.0)) NULL,
    [CELL_PROP_ID] AS             ((1))
);

