CREATE TABLE [dbo].[RPT_REPLACEMENT_CAR_CONTROL] (
    [USER_ID]                  NVARCHAR (50)   NOT NULL,
    [REPORT_TITLE]             NVARCHAR (50)   NULL,
    [REPORT_COMPANY]           NVARCHAR (50)   NULL,
    [REPORT_IMAGE]             NVARCHAR (250)  NULL,
    [MONTH]                    NVARCHAR (50)   NULL,
    [PERIOD_YEAR]              NVARCHAR (4)    NULL,
    [PLAT_NO]                  NVARCHAR (50)   NULL,
    [CATEGORY]                 NVARCHAR (250)  NULL,
    [VEHICLE_TYPE]             NVARCHAR (250)  NULL,
    [YEAR]                     NVARCHAR (4)    NULL,
    [COLOR]                    NVARCHAR (50)   NULL,
    [CURRENT_PARKING_LOCATION] NVARCHAR (250)  NULL,
    [BREAKDOWN_DAYS]           INT             NULL,
    [BREAKDOWN_PCT]            DECIMAL (18, 2) NULL,
    [IDLE_DAYS]                INT             NULL,
    [IDLE_PCT]                 DECIMAL (18, 2) NULL,
    [ACTIVE_DAYS]              INT             NULL,
    [ACTIVE_PCT]               DECIMAL (18, 2) NULL
);

