CREATE TABLE [dbo].[CASHIER_TRANSACTION_DETAIL] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [CASHIER_TRANSACTION_CODE] NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]         NVARCHAR (50)   NULL,
    [RECEIVED_REQUEST_CODE]    NVARCHAR (50)   NULL,
    [AGREEMENT_NO]             NVARCHAR (50)   NULL,
    [IS_PAID]                  NVARCHAR (1)    NOT NULL,
    [INNITIAL_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_DETAIL_ORIG_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [ORIG_AMOUNT]              DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_NONCASH_DETAIL_ORIG_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ORIG_CURRENCY_CODE]       NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]                DECIMAL (18, 6) CONSTRAINT [DF_CASHIER_NONCASH_DETAIL_EXCH_RATE] DEFAULT ((0)) NOT NULL,
    [BASE_AMOUNT]              DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_NONCASH_DETAIL_BASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INSTALLMENT_NO]           INT             NULL,
    [REMARKS]                  NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CASHIER_NONCASH_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CASHIER_TRANSACTION_DETAIL_CASHIER_TRANSACTION] FOREIGN KEY ([CASHIER_TRANSACTION_CODE]) REFERENCES [dbo].[CASHIER_TRANSACTION] ([CODE]),
    CONSTRAINT [FK_CASHIER_TRANSACTION_DETAIL_MASTER_TRANSACTION] FOREIGN KEY ([TRANSACTION_CODE]) REFERENCES [dbo].[MASTER_TRANSACTION] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaction kasir pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'CASHIER_TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaction pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request penerimaan pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data transaction tersebut sudah dilakukan proses pembayaran?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_PAID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'INNITIAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode jenis mata uang pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'REMARKS';

