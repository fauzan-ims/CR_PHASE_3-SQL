CREATE TABLE [dbo].[IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]         NVARCHAR (50)   NULL,
    [ASSET_NO]             NVARCHAR (50)   NULL,
    [BRANCH_CODE]          NVARCHAR (50)   NULL,
    [BRANCH_NAME]          NVARCHAR (250)  NULL,
    [INVOICE_TYPE]         NVARCHAR (10)   NULL,
    [INVOICE_DATE]         DATETIME        NULL,
    [INVOICE_NAME]         NVARCHAR (250)  NULL,
    [CLIENT_NO]            NVARCHAR (50)   NULL,
    [CLIENT_NAME]          NVARCHAR (250)  NULL,
    [CLIENT_ADDRESS]       NVARCHAR (4000) NULL,
    [CLIENT_AREA_PHONE_NO] NVARCHAR (4)    NULL,
    [CLIENT_PHONE_NO]      NVARCHAR (15)   NULL,
    [CLIENT_NPWP]          NVARCHAR (50)   NULL,
    [CURRENCY_CODE]        NVARCHAR (3)    NULL,
    [TAX_SCHEME_CODE]      NVARCHAR (50)   NULL,
    [TAX_SCHEME_NAME]      NVARCHAR (250)  NULL,
    [BILLING_NO]           INT             NULL,
    [DESCRIPTION]          NVARCHAR (4000) NULL,
    [QUANTITY]             INT             NULL,
    [BILLING_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_BILLING_AMOUNT] DEFAULT ((0)) NULL,
    [DISCOUNT_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_DISCOUNT_AMOUNT] DEFAULT ((0)) NULL,
    [PPN_PCT]              DECIMAL (9, 6)  CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_PPN_PCT] DEFAULT ((0)) NULL,
    [PPN_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_PPN_AMOUNT] DEFAULT ((0)) NULL,
    [PPH_PCT]              DECIMAL (9, 6)  CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_PPH_PCT] DEFAULT ((0)) NULL,
    [PPH_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_PPH_AMOUNT] DEFAULT ((0)) NULL,
    [TOTAL_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST_TOTAL_AMOUNT] DEFAULT ((0)) NULL,
    [REQUEST_STATUS]       NVARCHAR (10)   NULL,
    [REFF_CODE]            NVARCHAR (50)   NULL,
    [REFF_NAME]            NVARCHAR (250)  NULL,
    [SETTLE_DATE]          DATETIME        NULL,
    [JOB_STATUS]           NVARCHAR (10)   NULL,
    [FAILED_REMARKS]       NVARCHAR (4000) NULL,
    [CRE_DATE]             DATETIME        NULL,
    [CRE_BY]               NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NULL,
    [MOD_DATE]             DATETIME        NULL,
    [MOD_BY]               NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NULL,
    CONSTRAINT [PK_IFINPROC_INTERFACE_ADDTIONAL_INVOICE_REQUEST] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Type of invoice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'INVOICE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'CLIENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama Client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'CLIENT_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Angsuran Ke', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'BILLING_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NIlai PPN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai PPH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST', @level2type = N'COLUMN', @level2name = N'PPH_AMOUNT';

