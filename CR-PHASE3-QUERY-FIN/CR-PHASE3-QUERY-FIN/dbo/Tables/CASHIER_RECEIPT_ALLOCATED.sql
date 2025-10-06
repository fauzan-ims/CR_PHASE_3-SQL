CREATE TABLE [dbo].[CASHIER_RECEIPT_ALLOCATED] (
    [ID]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [CASHIER_CODE]         NVARCHAR (50) NOT NULL,
    [RECEIPT_CODE]         NVARCHAR (50) NOT NULL,
    [RECEIPT_STATUS]       NVARCHAR (50) NOT NULL,
    [RECEIPT_USE_DATE]     DATETIME      NULL,
    [RECEIPT_USE_TRX_CODE] NVARCHAR (50) NULL,
    [CRE_DATE]             DATETIME      NOT NULL,
    [CRE_BY]               NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15) NOT NULL,
    [MOD_DATE]             DATETIME      NOT NULL,
    [MOD_BY]               NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_CASHIER_RECEIPT_ALLOCATED] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CASHIER_RECEIPT_ALLOCATED_CASHIER_MAIN] FOREIGN KEY ([CASHIER_CODE]) REFERENCES [dbo].[CASHIER_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_CASHIER_RECEIPT_ALLOCATED_RECEIPT_MAIN] FOREIGN KEY ([RECEIPT_CODE]) REFERENCES [dbo].[RECEIPT_MAIN] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIPT_ALLOCATED', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cashier pada proses alokasi penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIPT_ALLOCATED', @level2type = N'COLUMN', @level2name = N'CASHIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode penerimaan pada proses alokasi penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIPT_ALLOCATED', @level2type = N'COLUMN', @level2name = N'RECEIPT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kwitansi digunakan pada proses alokasi penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIPT_ALLOCATED', @level2type = N'COLUMN', @level2name = N'RECEIPT_USE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaksi penggunaan kwitansi pada proses alokasi penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIPT_ALLOCATED', @level2type = N'COLUMN', @level2name = N'RECEIPT_USE_TRX_CODE';

