CREATE TABLE [sim].[DAT_DD_SCH_CAP] (
    [AIRLINE_DESIGNATOR]             VARCHAR (3)   NOT NULL,
    [FLIGHT_NUMBER]                  VARCHAR (5)   NOT NULL,
    [AIRLINE_DESIGNATOR_OP]          VARCHAR (3)   NULL,
    [FLIGHT_NUMBER_OP]               VARCHAR (5)   NULL,
    [DEPARTURE_STATION]              CHAR (3)      NULL,
    [ARRIVAL_STATION]                CHAR (3)      NULL,
    [DEPARTURE_DATE]                 SMALLDATETIME NULL,
    [TIME_VARIATION_DEPARTURE]       VARCHAR (255) NULL,
    [DEPARTURE_DATE_UTC]             SMALLDATETIME NULL,
    [ARRIVAL_DATE]                   SMALLDATETIME NULL,
    [TIME_VARIATION_ARRIVAL]         VARCHAR (255) NULL,
    [ARRIVAL_DATE_UTC]               SMALLDATETIME NULL,
    [AIRCRAFT_TYPE]                  VARCHAR (3)   NULL,
    [AIRCRAFT_CONFIGURATION_VERSION] VARCHAR (20)  NULL,
    [CAPACITY_C]                     INT           NULL,
    [CAPACITY_S]                     INT           NULL,
    [CAPACITY_W]                     INT           NULL,
    [LOAD_DATE]                      DATE          NULL
);

