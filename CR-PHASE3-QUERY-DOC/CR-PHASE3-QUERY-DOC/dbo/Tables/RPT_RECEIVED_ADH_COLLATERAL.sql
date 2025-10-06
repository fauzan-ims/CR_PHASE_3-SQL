CREATE TABLE [dbo].[RPT_RECEIVED_ADH_COLLATERAL] (
    [USER_ID]           NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]    NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]      NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]      NVARCHAR (50)   NULL,
    [BRANCH_CODE]       NVARCHAR (50)   NULL,
    [BRANCH_NAME]       NVARCHAR (50)   NULL,
    [FROM_DATE]         DATETIME        NULL,
    [TO_DATE]           DATETIME        NULL,
    [CUSTOMER_NAME]     NVARCHAR (50)   NULL,
    [DOCUMENT_NO]       NVARCHAR (50)   NULL,
    [AGREEMENT_NO]      NVARCHAR (50)   NULL,
    [DESCRIPTION]       NVARCHAR (4000) NULL,
    [DOCUMENT_NAME]     NVARCHAR (250)  NULL,
    [SUM_AGREEMENT]     INT             NULL,
    [RECEIVED_DATE]     DATETIME        NULL,
    [TRX_DATE]          DATETIME        NULL,
    [IS_CONDITION]      NVARCHAR (1)    NULL,
    [AO]                NVARCHAR (20)   NULL,
    [SUM_JENIS_OR_TYPE] INT             NULL,
    [SUM_UNIT]          INT             NULL
);

