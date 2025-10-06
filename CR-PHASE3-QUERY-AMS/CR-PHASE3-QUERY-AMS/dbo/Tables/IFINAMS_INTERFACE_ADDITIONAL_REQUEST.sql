CREATE TABLE [dbo].[IFINAMS_INTERFACE_ADDITIONAL_REQUEST] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]         NVARCHAR (50)   NULL,
    [ASSET_NO]             NVARCHAR (50)   NULL,
    [BRANCH_CODE]          NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]          NVARCHAR (250)  NOT NULL,
    [INVOICE_TYPE]         NVARCHAR (10)   NOT NULL,
    [INVOICE_DATE]         DATETIME        NOT NULL,
    [INVOICE_NAME]         NVARCHAR (250)  NOT NULL,
    [CLIENT_NO]            NVARCHAR (50)   NOT NULL,
    [CLIENT_NAME]          NVARCHAR (250)  NOT NULL,
    [CLIENT_ADDRESS]       NVARCHAR (4000) NOT NULL,
    [CLIENT_AREA_PHONE_NO] NVARCHAR (4)    NOT NULL,
    [CLIENT_PHONE_NO]      NVARCHAR (15)   NOT NULL,
    [CLIENT_NPWP]          NVARCHAR (50)   NULL,
    [CURRENCY_CODE]        NVARCHAR (3)    NOT NULL,
    [TAX_SCHEME_CODE]      NVARCHAR (50)   NOT NULL,
    [TAX_SCHEME_NAME]      NVARCHAR (250)  NOT NULL,
    [BILLING_NO]           INT             NOT NULL,
    [DESCRIPTION]          NVARCHAR (4000) NOT NULL,
    [QUANTITY]             INT             NOT NULL,
    [BILLING_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_BILLING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPN_PCT]              DECIMAL (9, 6)  CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_PPN_PCT] DEFAULT ((0)) NOT NULL,
    [PPN_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_PPN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPH_PCT]              DECIMAL (9, 6)  CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_PPH_PCT] DEFAULT ((0)) NOT NULL,
    [PPH_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_PPH_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_IFINAMS_INTERFACE_ADDITIONAL_REQUEST_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REQUEST_STATUS]       NVARCHAR (10)   NOT NULL,
    [REFF_CODE]            NVARCHAR (50)   NOT NULL,
    [REFF_NAME]            NVARCHAR (250)  NOT NULL,
    [SETTLE_DATE]          DATETIME        NULL,
    [JOB_STATUS]           NVARCHAR (10)   NULL,
    [FAILED_REMARKS]       NVARCHAR (4000) NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_IFINAMS_INTERFACE_ADDITIONAL_REQUEST] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Type of invoice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'INVOICE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'CLIENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama Client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'CLIENT_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Angsuran Ke', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'BILLING_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NIlai PPN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai PPH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IFINAMS_INTERFACE_ADDITIONAL_REQUEST', @level2type = N'COLUMN', @level2name = N'PPH_AMOUNT';

