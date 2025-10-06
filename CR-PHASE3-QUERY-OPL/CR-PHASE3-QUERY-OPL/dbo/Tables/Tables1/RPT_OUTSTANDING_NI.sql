CREATE TABLE [dbo].[RPT_OUTSTANDING_NI] (
    [USER_ID]              NVARCHAR (50)   NULL,
    [BRANCH_CODE]          NVARCHAR (50)   NULL,
    [AS_OF_DATE]           DATETIME        NULL,
    [REPORT_COMPANY]       NVARCHAR (250)  NULL,
    [REPORT_IMAGE]         NVARCHAR (250)  NULL,
    [REPORT_TITLE]         NVARCHAR (250)  NULL,
    [NO_SKD]               NVARCHAR (50)   NULL,
    [CLIENT_CODE]          NVARCHAR (50)   NULL,
    [CLIENT_NAME]          NVARCHAR (250)  NULL,
    [TYPE_KENDARAN]        NVARCHAR (250)  NULL,
    [TOTAL_UNIT]           INT             NULL,
    [TENOR]                INT             NULL,
    [PERIODE_BERJALAN]     INT             NULL,
    [SISA_TENOR]           INT             NULL,
    [HARGA_SEWA_PER_BULAN] DECIMAL (18, 2) NULL,
    [SISA_SEWA]            DECIMAL (18, 2) NULL,
    [RV_AMOUNT]            DECIMAL (18, 2) NULL,
    [SISA_AND_RV_AMOUNT]   DECIMAL (18, 2) NULL,
    [OS_NI_AMOUNT]         DECIMAL (18, 2) NULL,
    [BRANCH_NAME]          NVARCHAR (250)  NULL,
    [IS_CONDITION]         NVARCHAR (1)    NULL,
    [CRE_DATE]             DATETIME        NULL,
    [CRE_BY]               NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NULL,
    [MOD_DATE]             DATETIME        NULL,
    [MOD_BY]               NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NULL,
    [MONTH_HEADER]         NVARCHAR (50)   NULL,
    [YEAR_HEADER]          NVARCHAR (4)    NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_RPT_OUTSTANDING_NI_USER_ID_20250615]
    ON [dbo].[RPT_OUTSTANDING_NI]([USER_ID] ASC);

