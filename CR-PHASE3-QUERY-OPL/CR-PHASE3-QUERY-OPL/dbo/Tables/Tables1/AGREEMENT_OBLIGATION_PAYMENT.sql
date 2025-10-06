CREATE TABLE [dbo].[AGREEMENT_OBLIGATION_PAYMENT] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [OBLIGATION_CODE]     NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]        NVARCHAR (50)   NOT NULL,
    [ASSET_NO]            NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]          NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]      INT             NULL,
    [PAYMENT_DATE]        DATETIME        NOT NULL,
    [VALUE_DATE]          DATETIME        NOT NULL,
    [PAYMENT_SOURCE_TYPE] NVARCHAR (50)   NULL,
    [PAYMENT_SOURCE_NO]   NVARCHAR (50)   NOT NULL,
    [PAYMENT_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [IS_WAIVE]            NVARCHAR (1)    CONSTRAINT [DF_AGREEMENT_OBLIGATION_PAYMENT_IS_WAIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_OBLIGATION_PAYMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_AGREEMENT_OBLIGATION_PAYMENT_AGREEMENT_OBLIGATION] FOREIGN KEY ([OBLIGATION_CODE]) REFERENCES [dbo].[AGREEMENT_OBLIGATION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_AGREEMENT_OBLIGATION_PAYMENT_AGREEMENT_OBLIGATION1] FOREIGN KEY ([OBLIGATION_CODE]) REFERENCES [dbo].[AGREEMENT_OBLIGATION] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_OBLIGATION_PAYMENT_20240815]
    ON [dbo].[AGREEMENT_OBLIGATION_PAYMENT]([OBLIGATION_CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [AGREEMENT_OBLIGATION_PAYMENT_IDX_20250203]
    ON [dbo].[AGREEMENT_OBLIGATION_PAYMENT]([AGREEMENT_NO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode obligation pada proses pembayaran obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'OBLIGATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pembayaran pada proses pembayaran obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'PAYMENT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pembayaran tersebut di akui pada proses pembayaran obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe source pembayaran obligasi pada proses pembayaran obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'PAYMENT_SOURCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor source pada proses pembayaran obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'PAYMENT_SOURCE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada proses pembayaran obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'PAYMENT_AMOUNT';

