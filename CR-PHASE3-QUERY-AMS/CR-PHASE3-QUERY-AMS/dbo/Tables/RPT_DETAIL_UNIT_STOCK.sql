CREATE TABLE [dbo].[RPT_DETAIL_UNIT_STOCK] (
    [USER_ID]           NVARCHAR (50)  NOT NULL,
    [REPORT_COMPANY]    NVARCHAR (250) NOT NULL,
    [REPORT_TITLE]      NVARCHAR (250) NOT NULL,
    [REPORT_IMAGE]      NVARCHAR (50)  NULL,
    [STATUS_ALLOCATION] NVARCHAR (50)  NULL,
    [STATUS]            NVARCHAR (50)  NULL,
    [PARAMETER_MONTH]   INT            NULL,
    [W1]                INT            NULL,
    [W2]                INT            NULL,
    [W3]                INT            NULL,
    [W4]                INT            NULL,
    [DESC_MONTH]        NVARCHAR (20)  NULL
);

