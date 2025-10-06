CREATE TABLE [dbo].[RPT_PRINT_DETAIL_KONTRAK_OVERDUE] (
    [USER_ID]          NVARCHAR (50)   NOT NULL,
    [AS_OF_DATE]       DATETIME        NULL,
    [AGREEMENT_NO]     NVARCHAR (50)   NULL,
    [ASSET_NAME]       NVARCHAR (250)  NULL,
    [ASSET_COUNT]      INT             NULL,
    [INVOICE_NO]       NVARCHAR (50)   NULL,
    [PERIODE]          NVARCHAR (50)   NULL,
    [DPP_AMOUNT]       DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]       DECIMAL (18, 2) NULL,
    [PPH_AMOUNT]       DECIMAL (18, 2) NULL,
    [DPP_PPN_PPH]      DECIMAL (18, 2) NULL,
    [DPP_PPN]          DECIMAL (18, 2) NULL,
    [INVOICE_DUE_DATE] DATETIME        NULL,
    [OVD_DAYS]         INT             NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [CLIENT_NO]        NVARCHAR (50)   NULL
);

