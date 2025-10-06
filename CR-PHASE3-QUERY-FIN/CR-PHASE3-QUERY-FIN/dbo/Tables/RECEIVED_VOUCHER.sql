CREATE TABLE [dbo].[RECEIVED_VOUCHER] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [RECEIVED_STATUS]             NVARCHAR (10)   NOT NULL,
    [RECEIVED_FROM]               NVARCHAR (250)  NULL,
    [RECEIVED_TRANSACTION_DATE]   DATETIME        NOT NULL,
    [RECEIVED_VALUE_DATE]         DATETIME        NOT NULL,
    [RECEIVED_ORIG_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [RECEIVED_ORIG_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [RECEIVED_EXCH_RATE]          DECIMAL (18, 6) NOT NULL,
    [RECEIVED_BASE_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [RECEIVED_REMARKS]            NVARCHAR (4000) NOT NULL,
    [BRANCH_BANK_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_BANK_NAME]            NVARCHAR (250)  NOT NULL,
    [BRANCH_GL_LINK_CODE]         NVARCHAR (50)   NOT NULL,
    [IS_RECONCILE]                NVARCHAR (1)    CONSTRAINT [DF_RECEIVED_VOUCHER_IS_RECONCILE] DEFAULT ((0)) NOT NULL,
    [RECONCILE_DATE]              DATETIME        NULL,
    [REVERSAL_CODE]               NVARCHAR (50)   NULL,
    [REVERSAL_DATE]               DATETIME        NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECEIVED_VOUCHER] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses received voucher tersebut - HOLD, menginformasikan bahwa data received voucher tersebut belum diproses - CANCEL, menginformasikan bahwa data received voucher tersebut telah dibatalkan - POST, menginformasikan bahwa data received voucher tersebut telah diposting - REVERSE, menginformasikan bahwa data received voucher tersebut telah direversal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang mengirimkan data receipt voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya transaksi penerimaan pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_TRANSACTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pengakuan pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original penrimaan pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original yang digunakan pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECEIVED_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'BRANCH_GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data received voucher tersebut dilakukan proses rekonsel?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'IS_RECONCILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses rekonsel pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'RECONCILE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode reversal pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'REVERSAL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses reversal pada data received voucher tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_VOUCHER', @level2type = N'COLUMN', @level2name = N'REVERSAL_DATE';

