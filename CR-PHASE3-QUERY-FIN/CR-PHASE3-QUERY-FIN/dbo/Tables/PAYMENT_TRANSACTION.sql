CREATE TABLE [dbo].[PAYMENT_TRANSACTION] (
    [CODE]                       NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                NVARCHAR (250)  NOT NULL,
    [PAYMENT_STATUS]             NVARCHAR (10)   NOT NULL,
    [PAYMENT_TRANSACTION_DATE]   DATETIME        NOT NULL,
    [PAYMENT_VALUE_DATE]         DATETIME        NOT NULL,
    [PAYMENT_ORIG_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [PAYMENT_ORIG_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [PAYMENT_EXCH_RATE]          DECIMAL (18, 6) NOT NULL,
    [PAYMENT_BASE_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [PAYMENT_TYPE]               NVARCHAR (10)   NOT NULL,
    [PAYMENT_REMARKS]            NVARCHAR (4000) NOT NULL,
    [BRANCH_BANK_CODE]           NVARCHAR (50)   NULL,
    [BANK_GL_LINK_CODE]          NVARCHAR (50)   NULL,
    [BRANCH_BANK_NAME]           NVARCHAR (250)  NULL,
    [BRANCH_BANK_ACCOUNT_NO]     NVARCHAR (50)   NULL,
    [TOTAL_TAX_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_PAYMENT_TRANSACTION_TOTAL_TAX_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PDC_CODE]                   NVARCHAR (50)   NULL,
    [PDC_NO]                     NVARCHAR (50)   NULL,
    [TO_BANK_NAME]               NVARCHAR (250)  NOT NULL,
    [TO_BANK_ACCOUNT_NAME]       NVARCHAR (250)  NOT NULL,
    [TO_BANK_ACCOUNT_NO]         NVARCHAR (50)   NOT NULL,
    [IS_RECONCILE]               NVARCHAR (1)    CONSTRAINT [DF_PAYMENT_FROM_CORE_IS_RECONCILE] DEFAULT ((0)) NOT NULL,
    [RECONCILE_DATE]             DATETIME        NULL,
    [REVERSAL_CODE]              NVARCHAR (50)   NULL,
    [REVERSAL_DATE]              DATETIME        NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_PAYMENT_FROM_CORE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pembayaran pada proses transaksi pembayaran tersebut - HOLD, menginformasikan bahwa transaksi pembayaran tersebut belum diproses - CANCEL, menginformasikan bahwa transaksi pembayaran tersebut telah ditabalkan - PAID, menginformasikan bahwa transaksi pembayaran tersebut telah dibatalkan - REVERSE, menginformasikan bahwa transaksi pembayaran tersebut telah di reversal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_TRANSACTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal diakuinya transaksi pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pembayaran original pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pada proses transaksi pembayaran tersebut - TRANSFER, menginformasikan bahwa transaksi pembayaran tersebut dilakukan dengan cara transfer - PDC, menginformasikan bahwa transaksi pembayaran tersebut dilakukan dengan cek / pdc - PAYMENTPOINT, menginformasikan bahwa transaksi pembayaran tersebut dilakukan pada payment point - CASH, menginformasikan bahwa transaksi pembayaran tersebut dilakukan dengan uang cash - AUTODEBIT, menginformasikan bahwa transaksi pembayaran tersebut dilakukan dengan cara autodebit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PAYMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada data transaksi penerimaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BANK_GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode PDC pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PDC_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor PDC pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PDC_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama bank tujuan pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TO_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama rekening bank tujuan pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TO_BANK_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor rekening bank tujuan pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TO_BANK_ACCOUNT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah transaksi pembayaran tersebut dilakukan proses reconcile?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_RECONCILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses reconcile pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECONCILE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode reversal pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'REVERSAL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal reversal pada proses transaksi pembayaran tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_TRANSACTION', @level2type = N'COLUMN', @level2name = N'REVERSAL_DATE';

