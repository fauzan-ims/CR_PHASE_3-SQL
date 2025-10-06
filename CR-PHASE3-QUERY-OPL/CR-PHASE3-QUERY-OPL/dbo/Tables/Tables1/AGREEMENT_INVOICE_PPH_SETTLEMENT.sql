CREATE TABLE [dbo].[AGREEMENT_INVOICE_PPH_SETTLEMENT] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_INVOICE_PPH_CODE] NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]                 NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]               NVARCHAR (50)   NOT NULL,
    [ASSET_NO]                   NVARCHAR (50)   NOT NULL,
    [TRANSACTION_NO]             NVARCHAR (50)   NOT NULL,
    [TRANSACTION_TYPE]           NVARCHAR (20)   NOT NULL,
    [PAYMENT_DATE]               DATETIME        NOT NULL,
    [PAYMENT_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_PPH_SETTLEMENT_PAYMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DESCRIPTION]                NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [FK_AGREEMENT_INVOICE_PPH_SETTLEMENT_AGREEMENT_INVOICE_PPH] FOREIGN KEY ([AGREEMENT_INVOICE_PPH_CODE]) REFERENCES [dbo].[AGREEMENT_INVOICE_PPH] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_INVOICE_PPH_SETTLEMENT', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PAYMENT, CREDIT NOTE ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_INVOICE_PPH_SETTLEMENT', @level2type = N'COLUMN', @level2name = N'TRANSACTION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PAYMENT, CREDIT NOTE ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_INVOICE_PPH_SETTLEMENT', @level2type = N'COLUMN', @level2name = N'TRANSACTION_TYPE';

