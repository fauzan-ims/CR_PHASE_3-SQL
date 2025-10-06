CREATE TABLE [dbo].[PAYMENT_TRANSACTION_DETAIL] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [PAYMENT_TRANSACTION_CODE] NVARCHAR (50)   NOT NULL,
    [PAYMENT_REQUEST_CODE]     NVARCHAR (50)   NOT NULL,
    [ORIG_CURR_CODE]           NVARCHAR (3)    NOT NULL,
    [ORIG_AMOUNT]              DECIMAL (18, 2) NOT NULL,
    [EXCH_RATE]                DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]              DECIMAL (18, 2) NOT NULL,
    [TAX_AMOUNT]               DECIMAL (18, 2) CONSTRAINT [DF_PAYMENT_FROM_CORE_DETAIL_TAX_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_PAYMENT_FROM_CORE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PAYMENT_FROM_CORE_DETAIL_PAYMENT_FROM_CORE] FOREIGN KEY ([PAYMENT_TRANSACTION_CODE]) REFERENCES [dbo].[PAYMENT_TRANSACTION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_PAYMENT_FROM_CORE_DETAIL_PAYMENT_REQUEST] FOREIGN KEY ([PAYMENT_REQUEST_CODE]) REFERENCES [dbo].[PAYMENT_REQUEST] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_PAYMENT_TRANSACTION_DETAIL_PAYMENT_REQUEST_CODE_20250615]
    ON [dbo].[PAYMENT_TRANSACTION_DETAIL]([PAYMENT_REQUEST_CODE] ASC)
    INCLUDE([PAYMENT_TRANSACTION_CODE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pembayaran from core pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'PAYMENT_TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode payment request pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'PAYMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_CURR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pembayaran original pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pajak pada data payment transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'TAX_AMOUNT';

