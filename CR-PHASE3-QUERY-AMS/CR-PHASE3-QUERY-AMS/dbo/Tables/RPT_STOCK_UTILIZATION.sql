CREATE TABLE [dbo].[RPT_STOCK_UTILIZATION] (
    [USER_ID]        NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY] NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]   NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]   NVARCHAR (50)   NULL,
    [AS_OF_DATE]     DATETIME        NULL,
    [LEASED_OBJECT]  NVARCHAR (250)  NULL,
    [YEAR]           INT             NULL,
    [PLAT_NO]        NVARCHAR (50)   NULL,
    [STATUS]         NVARCHAR (50)   NULL,
    [REMARKS]        NVARCHAR (4000) NULL,
    [SHARE_DATE]     DATETIME        NULL,
    [AGING]          INT             NULL,
    [IS_CONDITION]   NVARCHAR (1)    NULL
);

