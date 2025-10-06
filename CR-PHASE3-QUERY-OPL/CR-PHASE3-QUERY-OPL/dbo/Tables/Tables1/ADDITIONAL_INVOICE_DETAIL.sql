CREATE TABLE [dbo].[ADDITIONAL_INVOICE_DETAIL] (
    [ID]                              BIGINT          IDENTITY (1, 1) NOT NULL,
    [ADDITIONAL_INVOICE_CODE]         NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]                    NVARCHAR (50)   NOT NULL,
    [ASSET_NO]                        NVARCHAR (50)   NULL,
    [TAX_SCHEME_CODE]                 NVARCHAR (50)   NOT NULL,
    [TAX_SCHEME_NAME]                 NVARCHAR (250)  NOT NULL,
    [BILLING_NO]                      INT             NOT NULL,
    [DESCRIPTION]                     NVARCHAR (4000) NOT NULL,
    [QUANTITY]                        INT             NOT NULL,
    [BILLING_AMOUNT]                  DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_BILLING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]                 DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPN_PCT]                         DECIMAL (9, 6)  CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_PPN_PCT] DEFAULT ((0)) NOT NULL,
    [PPN_AMOUNT]                      DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_PPN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPH_PCT]                         DECIMAL (9, 6)  CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_PPH_PCT] DEFAULT ((0)) NOT NULL,
    [PPH_AMOUNT]                      DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_PPH_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_AMOUNT]                    DECIMAL (18, 2) CONSTRAINT [DF_ADDITIONAL_INVOICE_DETAIL_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REFF_CODE]                       NVARCHAR (50)   NULL,
    [REFF_NAME]                       NVARCHAR (250)  NULL,
    [ADDITIONAL_INVOICE_REQUEST_CODE] NVARCHAR (50)   NULL,
    [CRE_DATE]                        DATETIME        NOT NULL,
    [CRE_BY]                          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                        DATETIME        NOT NULL,
    [MOD_BY]                          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                  NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ADDITIONAL_INVOICE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ADDITIONAL_INVOICE_DETAIL_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]),
    CONSTRAINT [FK_ADDITIONAL_INVOICE_DETAIL_AGREEMENT_INVOICE] FOREIGN KEY ([ADDITIONAL_INVOICE_CODE]) REFERENCES [dbo].[ADDITIONAL_INVOICE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_ADDITIONAL_INVOICE_DETAIL_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE_DETAIL', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Angsuran Ke', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE_DETAIL', @level2type = N'COLUMN', @level2name = N'BILLING_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NIlai PPN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE_DETAIL', @level2type = N'COLUMN', @level2name = N'PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai PPH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ADDITIONAL_INVOICE_DETAIL', @level2type = N'COLUMN', @level2name = N'PPH_AMOUNT';

