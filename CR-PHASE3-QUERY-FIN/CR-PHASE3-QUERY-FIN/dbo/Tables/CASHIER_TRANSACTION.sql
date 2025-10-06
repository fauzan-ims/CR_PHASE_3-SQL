CREATE TABLE [dbo].[CASHIER_TRANSACTION] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [CASHIER_MAIN_CODE]           NVARCHAR (50)   NOT NULL,
    [CASHIER_STATUS]              NVARCHAR (10)   NOT NULL,
    [CASHIER_TRX_DATE]            DATETIME        NOT NULL,
    [CASHIER_VALUE_DATE]          DATETIME        NULL,
    [CASHIER_TYPE]                NVARCHAR (10)   CONSTRAINT [DF_CASHIER_NONCASH_NONCASH_TYPE] DEFAULT (N'') NOT NULL,
    [CASHIER_ORIG_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [CASHIER_CURRENCY_CODE]       NVARCHAR (3)    NOT NULL,
    [CASHIER_EXCH_RATE]           DECIMAL (18, 6) NOT NULL,
    [CASHIER_BASE_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [CASHIER_REMARKS]             NVARCHAR (4000) NOT NULL,
    [RECEIVED_REQUEST_CODE]       NVARCHAR (50)   NULL,
    [AGREEMENT_NO]                NVARCHAR (50)   NULL,
    [DEPOSIT_AMOUNT]              DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_DEPOSIT_AMOUNT_1] DEFAULT ((0)) NOT NULL,
    [IS_USE_DEPOSIT]              NVARCHAR (1)    CONSTRAINT [DF_CASHIER_TRANSACTION_IS_USE_DEPOSIT_1] DEFAULT ((0)) NOT NULL,
    [DEPOSIT_USED_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_DEPOSIT_USED_AMOUNT_1] DEFAULT ((0)) NOT NULL,
    [RECEIVED_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_RECEIVED_AMOUNT_1] DEFAULT ((0)) NOT NULL,
    [RECEIPT_CODE]                NVARCHAR (50)   NULL,
    [IS_RECEIVED_REQUEST]         NVARCHAR (1)    CONSTRAINT [DF_CASHIER_NONCASH_IS_RECEIVED_REQUEST] DEFAULT ((0)) NOT NULL,
    [CARD_RECEIPT_REFF_NO]        NVARCHAR (50)   NULL,
    [CARD_BANK_NAME]              NVARCHAR (250)  NULL,
    [CARD_ACCOUNT_NAME]           NVARCHAR (250)  NULL,
    [BRANCH_BANK_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_BANK_NAME]            NVARCHAR (250)  NOT NULL,
    [BANK_GL_LINK_CODE]           NVARCHAR (50)   NULL,
    [PDC_CODE]                    NVARCHAR (50)   NULL,
    [PDC_NO]                      NVARCHAR (50)   NULL,
    [RECEIVED_FROM]               NVARCHAR (50)   NOT NULL,
    [RECEIVED_COLLECTOR_CODE]     NVARCHAR (50)   NULL,
    [RECEIVED_COLLECTOR_NAME]     NVARCHAR (250)  NULL,
    [RECEIVED_PAYOR_NAME]         NVARCHAR (250)  NULL,
    [RECEIVED_PAYOR_AREA_NO_HP]   NVARCHAR (4)    NULL,
    [RECEIVED_PAYOR_NO_HP]        NVARCHAR (15)   NULL,
    [RECEIVED_PAYOR_REFERENCE_NO] NVARCHAR (50)   NULL,
    [REVERSAL_CODE]               NVARCHAR (50)   NULL,
    [REVERSAL_DATE]               DATETIME        NULL,
    [PRINT_COUNT]                 INT             NOT NULL,
    [PRINT_MAX_COUNT]             INT             NOT NULL,
    [REFF_NO]                     NVARCHAR (250)  NULL,
    [IS_RECONCILE]                NVARCHAR (1)    CONSTRAINT [DF_CASHIER_IS_RECONCILE] DEFAULT ((0)) NOT NULL,
    [RECONCILE_DATE]              DATETIME        NULL,
    [VOUCHER_NO]                  NVARCHAR (50)   NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [BANK_ACCOUNT_NAME]           NVARCHAR (250)  NULL,
    [BANK_ACCOUNT_NO]             NVARCHAR (50)   NULL,
    [IS_PROCESS]                  NVARCHAR (1)    NULL,
    [CLIENT_NO]                   NVARCHAR (50)   NULL,
    [CLIENT_NAME]                 NVARCHAR (250)  NULL,
    CONSTRAINT [PK_CASHIER_NONCASH] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_CASHIER_TRANSACTION_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_CASHIER_TRANSACTION_JURNAL_GL_LINK] FOREIGN KEY ([BANK_GL_LINK_CODE]) REFERENCES [dbo].[JOURNAL_GL_LINK] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cashier pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_MAIN_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi cashier tersebut di proses', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_TRX_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi cashier tersebut di akui', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe cashier pada proses transaksi cashier tersebut - CASH, menginformasikan bahwa transaksi tersebut merupakan transaksi cash - BANK, menginformasikan bahwa transaksi cashier tersebut merupakan transaksi non cash', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original transaksi cashier pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi cashier setelah dikalikan dengan nilai tukar mata uang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CASHIER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original transaksi cashier pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original transaksi cashier pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_USE_DEPOSIT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original transaksi cashier pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'DEPOSIT_USED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original transaksi cashier pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kwitansi pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIPT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data transaksi cashier tersebut berasal dari proses cashier received request?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_RECEIVED_REQUEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi kwitansi EDC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CARD_RECEIPT_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama EDC bank jika pembayaran dilakukan melalui EDC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CARD_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama akun bank jika pembayaran dilakukan melalui EDC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CARD_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode PDC pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PDC_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor PDC pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PDC_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang melakukan penerimaan pada proses transaksi cashier tersebut - CLIENT, menginformasikan bahwa pembayaran diterima oleh client langsung - COLLECTOR, menginformasikan bahwa pembayaran diterima oleh collector - OTHER, menginformasikan bahwa pembayaran dilakukan selain dari client dan collector', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pembayar pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pembayar pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_COLLECTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pembayar pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_PAYOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor operator handphone pembayar pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_PAYOR_AREA_NO_HP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor handphone pembayar pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_PAYOR_NO_HP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor reference pembayar pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECEIVED_PAYOR_REFERENCE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode reversal pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'REVERSAL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi cashier tersebut dilakukan proses reversal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'REVERSAL_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah berapa kali dilakukan cetak kwitansi pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PRINT_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas maksimal berapa kali kwitansi pada proses transaksi cashier tersebut boleh dicetak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'PRINT_MAX_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada proses transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah transaksi cashier tersebut dilakukan proses rekonsel?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_RECONCILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses rekonsel pada transaksi cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECONCILE_DATE';

