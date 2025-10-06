CREATE TABLE [dbo].[ADDITIONAL_INVOICE] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [INVOICE_TYPE]          NVARCHAR (10)   NOT NULL,
    [INVOICE_DATE]          DATETIME        NOT NULL,
    [INVOICE_DUE_DATE]      DATETIME        NULL,
    [INVOICE_NAME]          NVARCHAR (250)  NOT NULL,
    [INVOICE_STATUS]        NVARCHAR (10)   NOT NULL,
    [CLIENT_NO]             NVARCHAR (50)   NULL,
    [CLIENT_NAME]           NVARCHAR (250)  NOT NULL,
    [CLIENT_ADDRESS]        NVARCHAR (4000) NOT NULL,
    [CLIENT_AREA_PHONE_NO]  NVARCHAR (4)    NOT NULL,
    [CLIENT_PHONE_NO]       NVARCHAR (15)   NOT NULL,
    [CLIENT_NPWP]           NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]         NVARCHAR (3)    NOT NULL,
    [TOTAL_BILLING_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_DISCOUNT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_TOTAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_PPN_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_TOTAL_PPN] DEFAULT ((0)) NOT NULL,
    [TOTAL_PPH_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_TOTAL_PPH] DEFAULT ((0)) NOT NULL,
    [TOTAL_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ADDITIONAL_INVOICE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Type of invoice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'INVOICE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'CLIENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama Client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'CLIENT_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total tagihan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_BILLING_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total PPN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total PPH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_PPH_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total Invoice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';

