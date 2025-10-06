CREATE TABLE [dbo].[PAYMENT_VOUCHER] (
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
    [BRANCH_BANK_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_BANK_NAME]           NVARCHAR (250)  NOT NULL,
    [BRANCH_GL_LINK_CODE]        NVARCHAR (50)   NULL,
    [PDC_CODE]                   NVARCHAR (50)   NULL,
    [PDC_NO]                     NVARCHAR (50)   NULL,
    [TO_BANK_NAME]               NVARCHAR (250)  NULL,
    [TO_BANK_ACCOUNT_NAME]       NVARCHAR (250)  NULL,
    [TO_BANK_ACCOUNT_NO]         NVARCHAR (50)   NULL,
    [IS_RECONCILE]               NVARCHAR (1)    CONSTRAINT [DF_PAYMENT_VOUCHER_IS_RECONCILE] DEFAULT ((0)) NOT NULL,
    [RECONCILE_DATE]             DATETIME        NULL,
    [REVERSAL_CODE]              NVARCHAR (50)   NULL,
    [REVERSAL_DATE]              DATETIME        NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_PAYMENT_VOUCHER] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pembayaran pada proses payment voucher tersebut - HOLD, menginformasikan bahwa data payment voucher tersebut belum diproses - CANCEL, menginformasikan bahwa data payment voucher tersebut telah dibatalkan - PAID, menginformasikan bahwa data payment voucher tersebut telah dibayar - REVERSE, menginformasikan bahwa data payment voucher tersebut telah direversal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi payment voucher tersebut dilakukan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_TRANSACTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi payment voucher tersebut di akui', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi payment voucher setelah dikalikan dengan nilai tukar mata uang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TRANSFER, PDC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PAYMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode PDC pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PDC_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor PDC pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'PDC_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tujuan transaksi pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'TO_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama rekening bank tujuan transaksi pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'TO_BANK_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor rekening bank tujuan transaksi pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'TO_BANK_ACCOUNT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data payment voucher tersebut dilakukan proses rekonsel?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'IS_RECONCILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi payment voucher tersebut dilakukan proses rekonsel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECONCILE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode reversal pada proses payment voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'REVERSAL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi payment voucher tersebut dilakukan proses reversal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER', @level2type = N'COLUMN', @level2name = N'REVERSAL_DATE';

