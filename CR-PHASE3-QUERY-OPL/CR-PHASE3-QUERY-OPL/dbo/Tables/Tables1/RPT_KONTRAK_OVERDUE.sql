CREATE TABLE [dbo].[RPT_KONTRAK_OVERDUE] (
    [USER_ID]                   NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]            NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]              NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]              NVARCHAR (250)  NOT NULL,
    [BRANCH_CODE]               NVARCHAR (50)   NULL,
    [BRANCH_NAME]               NVARCHAR (50)   NULL,
    [AS_OF_DATE]                DATETIME        NULL,
    [AGREEMENT_NO]              NVARCHAR (50)   NULL,
    [CLIENT_NAME]               NVARCHAR (250)  NULL,
    [PERIODE]                   INT             NULL,
    [OVERDUE_DAYS]              INT             NULL,
    [OVERDUE_RENTAL_AMOUNT]     DECIMAL (18, 2) NULL,
    [OUTSTANDING_RENTAL_AMOUNT] DECIMAL (18, 2) NULL,
    [OUTSTANDING_PERIODE]       INT             NULL,
    [OVERDUE_DATE]              DATETIME        NULL,
    [OVERDUE_INVOICE_AMOUNT]    DECIMAL (18, 2) NULL,
    [RENTAL_AMOUNT]             DECIMAL (18, 2) NULL,
    [IS_CONDITION]              NVARCHAR (1)    NULL
);

