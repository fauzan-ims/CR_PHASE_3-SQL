CREATE TABLE [dbo].[RPT_INVOICE_LIST] (
    [USER_ID]             NVARCHAR (50)   NULL,
    [REPORT_COMPANY]      NVARCHAR (250)  NULL,
    [REPORT_IMAGE]        NVARCHAR (250)  NULL,
    [REPORT_TITLE]        NVARCHAR (250)  NULL,
    [FROM_DATE]           DATETIME        NULL,
    [TO_DATE]             DATETIME        NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NULL,
    [INVOICE_NO]          NVARCHAR (50)   NULL,
    [INVOICE_TYPE]        NVARCHAR (50)   NULL,
    [DESCRIPTION]         NVARCHAR (250)  NULL,
    [INVOICE_DATE]        DATETIME        NULL,
    [INVOICE_DUE_DATE]    DATETIME        NULL,
    [STATUS]              NVARCHAR (50)   NULL,
    [INVOICE_AMOUNT]      DECIMAL (18, 2) NULL,
    [DISCOUNT_AMOUNT]     DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]          DECIMAL (18, 2) NULL,
    [PPH_AMOUNT]          DECIMAL (18, 2) NULL,
    [RENTAL_AMOUNT]       DECIMAL (18, 2) NULL,
    [CURRENCY]            NVARCHAR (5)    NULL,
    [FAKTUR_NO]           NVARCHAR (50)   NULL,
    [CLIENT_NAME]         NVARCHAR (250)  NULL,
    [SETTLEMENT_PPH_NO]   NVARCHAR (50)   NULL,
    [SETTLEMENT_PPH_DATE] DATETIME        NULL,
    [IS_CONDITION]        NVARCHAR (1)    NULL,
    [CRE_DATE]            DATETIME        NULL,
    [CRE_BY]              NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NULL,
    [MOD_DATE]            DATETIME        NULL,
    [MOD_BY]              NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NULL,
    [NETT_AMOUNT]         DECIMAL (18, 2) NULL,
    [AGREEMENT_NO]        NVARCHAR (50)   NULL,
    [PAYMENT_DATE]        DATETIME        NULL,
    [PAYMENT_AMOUNT]      DECIMAL (18, 2) NULL,
    [DPP_NILAI_LAIN]      DECIMAL (18, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_RPT_INVOICE_LIST_USER_ID_20250615]
    ON [dbo].[RPT_INVOICE_LIST]([USER_ID] ASC);

