CREATE TABLE [dbo].[ACCOUNT_TRANSFER] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [TRANSFER_STATUS]       NVARCHAR (10)   NOT NULL,
    [TRANSFER_TRX_DATE]     DATETIME        NOT NULL,
    [TRANSFER_VALUE_DATE]   DATETIME        NOT NULL,
    [TRANSFER_REMARKS]      NVARCHAR (4000) NOT NULL,
    [CASHIER_CODE]          NVARCHAR (50)   NULL,
    [CASHIER_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_ACCOUNT_TRANSFER_CASHIER_AMOUNT] DEFAULT ((0)) NULL,
    [IS_FROM]               NVARCHAR (1)    NULL,
    [FROM_BRANCH_CODE]      NVARCHAR (50)   NOT NULL,
    [FROM_BRANCH_NAME]      NVARCHAR (250)  NOT NULL,
    [FROM_CURRENCY_CODE]    NVARCHAR (3)    NULL,
    [FROM_EXCH_RATE]        DECIMAL (18, 6) CONSTRAINT [DF_ACCOUNT_TRANSFER_TRANSFER_EXCH_RATE1] DEFAULT ((1)) NOT NULL,
    [FROM_ORIG_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_ACCOUNT_TRANSFER_TRANSFER_ORIG_AMOUNT] DEFAULT ((0)) NOT NULL,
    [FROM_BRANCH_BANK_CODE] NVARCHAR (50)   NULL,
    [FROM_BRANCH_BANK_NAME] NVARCHAR (250)  NULL,
    [FROM_GL_LINK_CODE]     NVARCHAR (50)   NULL,
    [TO_BRANCH_CODE]        NVARCHAR (50)   NULL,
    [TO_BRANCH_NAME]        NVARCHAR (250)  NULL,
    [TO_CURRENCY_CODE]      NVARCHAR (3)    NULL,
    [TO_EXCH_RATE]          DECIMAL (18, 6) CONSTRAINT [DF_ACCOUNT_TRANSFER_TRANSFER_EXCH_RATE] DEFAULT ((0)) NOT NULL,
    [TO_ORIG_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_ACCOUNT_TRANSFER_TRANSFER_BASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TO_BRANCH_BANK_CODE]   NVARCHAR (50)   NULL,
    [TO_BRANCH_BANK_NAME]   NVARCHAR (250)  NULL,
    [TO_GL_LINK_CODE]       NVARCHAR (50)   NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ACCOUNT_TRANSFER] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TRANSFER_TRX_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tanggal pengakuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TRANSFER_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TRANSFER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kasir pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'CASHIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kasir pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'CASHIER_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_GL_LINK_CODE';

