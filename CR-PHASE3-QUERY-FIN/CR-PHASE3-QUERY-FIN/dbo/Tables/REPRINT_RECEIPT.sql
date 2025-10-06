CREATE TABLE [dbo].[REPRINT_RECEIPT] (
    [CODE]                NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NOT NULL,
    [REPRINT_STATUS]      NVARCHAR (10)   NOT NULL,
    [REPRINT_DATE]        DATETIME        NOT NULL,
    [REPRINT_REASON_CODE] NVARCHAR (50)   NOT NULL,
    [REPRINT_REMARKS]     NVARCHAR (4000) NOT NULL,
    [CASHIER_TYPE]        NVARCHAR (10)   NOT NULL,
    [CASHIER_CODE]        NVARCHAR (50)   NOT NULL,
    [OLD_RECEIPT_CODE]    NVARCHAR (50)   NOT NULL,
    [NEW_RECEIPT_CODE]    NVARCHAR (50)   NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_REPRINT_RECEIPT] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses reprint kwitansi tersebut - HOLD, menginformasikan bahwa proses reprint kwitansi tersebut belum diproses - POST, menginformasikan bahwa proses reprint kwitansi tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa proses reprint kwitansi tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'REPRINT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'REPRINT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode alasan kenapa dilakukan proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'REPRINT_REASON_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'REPRINT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe cashier pada proses cetak ulang kwitansi tersebut - CASH, menginformasikan bahwa pembayaran dilakukan secara cash - BANK, menginformasikan bahwa pembayaran dilakukan secara non cash', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'CASHIER_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kasir pada proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'CASHIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kwitansi yang lama pada proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'OLD_RECEIPT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kwitansi yang baru pada proses reprint kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPRINT_RECEIPT', @level2type = N'COLUMN', @level2name = N'NEW_RECEIPT_CODE';

