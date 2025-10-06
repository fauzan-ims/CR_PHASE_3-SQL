CREATE TABLE [dbo].[RPT_OVERDUE] (
    [USER_ID]                NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NULL,
    [AS_OF_DATE]             DATETIME        NULL,
    [REPORT_COMPANY]         NVARCHAR (250)  NULL,
    [REPORT_IMAGE]           NVARCHAR (250)  NULL,
    [REPORT_TITLE]           NVARCHAR (250)  NULL,
    [AGREEMENT_NO]           NVARCHAR (50)   NULL,
    [CUSTOMER_CODE]          NVARCHAR (50)   NULL,
    [CUSTOMER_NAME]          NVARCHAR (250)  NULL,
    [TOTAL_PERIODE]          INT             NULL,
    [RUNNING_PERIOD]         NVARCHAR (50)   NULL,
    [TOP_PERIOD]             INT             NULL,
    [TOP_DAYS]               INT             NULL,
    [TOP_DATE]               DATETIME        NULL,
    [RENTAL_FEE_EXCLUDE_VAT] DECIMAL (18, 2) NULL,
    [RENTAL_FEE_INCLUDE_VAT] DECIMAL (18, 2) NULL,
    [OD_PCT]                 DECIMAL (18, 2) NULL,
    [AMOUNT_OD_EXCLUDE_VAT]  DECIMAL (18, 2) NULL,
    [OD_DAYS]                INT             NULL,
    [AGREEMENT_STATUS]       NVARCHAR (50)   NULL,
    [MARKETING]              NVARCHAR (250)  NULL,
    [MARKETING_LEADER]       NVARCHAR (250)  NULL,
    [STATUS_UNIT]            NVARCHAR (50)   NULL,
    [IS_CONDITION]           NVARCHAR (1)    NULL,
    [CRE_DATE]               DATETIME        NULL,
    [CRE_BY]                 NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NULL,
    [MOD_DATE]               DATETIME        NULL,
    [MOD_BY]                 NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NULL,
    [FILTER_BRANCH]          NVARCHAR (250)  NULL,
    [AMOUNT_OD_INCLUDE_VAT]  DECIMAL (18, 2) NULL,
    [INVOICE_PAID]           NVARCHAR (50)   NULL,
    [INVOICE_NOT_DUE]        NVARCHAR (50)   NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_RPT_OVERDUE_20231003]
    ON [dbo].[RPT_OVERDUE]([USER_ID] ASC);

