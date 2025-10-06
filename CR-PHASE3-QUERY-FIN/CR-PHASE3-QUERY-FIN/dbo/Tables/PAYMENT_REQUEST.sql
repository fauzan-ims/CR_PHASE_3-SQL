CREATE TABLE [dbo].[PAYMENT_REQUEST] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [PAYMENT_BRANCH_CODE]      NVARCHAR (50)   NULL,
    [PAYMENT_BRANCH_NAME]      NVARCHAR (250)  NULL,
    [PAYMENT_SOURCE]           NVARCHAR (50)   NOT NULL,
    [PAYMENT_REQUEST_DATE]     DATETIME        NOT NULL,
    [PAYMENT_SOURCE_NO]        NVARCHAR (50)   NOT NULL,
    [PAYMENT_STATUS]           NVARCHAR (10)   NOT NULL,
    [PAYMENT_CURRENCY_CODE]    NVARCHAR (3)    CONSTRAINT [DF_PAYMENT_REQUEST_PAYMENT_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [PAYMENT_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_PAYMENT_REQUEST_PAYMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PAYMENT_TO]               NVARCHAR (250)  CONSTRAINT [DF_PAYMENT_REQUEST_PAYMENT_TO] DEFAULT (N'HOLD') NOT NULL,
    [PAYMENT_REMARKS]          NVARCHAR (4000) CONSTRAINT [DF_PAYMENT_REQUEST_PAYMENT_AMOUNT1_1] DEFAULT ('') NOT NULL,
    [TO_BANK_NAME]             NVARCHAR (250)  NOT NULL,
    [TO_BANK_ACCOUNT_NAME]     NVARCHAR (250)  NOT NULL,
    [TO_BANK_ACCOUNT_NO]       NVARCHAR (50)   NOT NULL,
    [PAYMENT_TRANSACTION_CODE] NVARCHAR (50)   NULL,
    [TAX_TYPE]                 NVARCHAR (10)   NULL,
    [TAX_FILE_NO]              NVARCHAR (50)   NULL,
    [TAX_PAYER_REFF_CODE]      NVARCHAR (50)   NULL,
    [TAX_FILE_NAME]            NVARCHAR (50)   NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_PAYMENT_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PAYMENT_REQUEST_20241031]
    ON [dbo].[PAYMENT_REQUEST]([PAYMENT_SOURCE_NO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asal pembayaran pada proses payment reequest tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_SOURCE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor source pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_SOURCE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'HOLD,ON PROCESS, PAID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dibayarkan pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama bank tujuan pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'TO_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama rekening bank tujuan pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'TO_BANK_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor rekening bank tujuan pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'TO_BANK_ACCOUNT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaction pada proses payment request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PAYMENT_TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'kode pembayar pajak di master setting.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'TAX_PAYER_REFF_CODE';

