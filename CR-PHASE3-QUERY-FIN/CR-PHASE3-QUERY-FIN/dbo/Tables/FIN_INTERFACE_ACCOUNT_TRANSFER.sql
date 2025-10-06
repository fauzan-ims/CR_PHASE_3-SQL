CREATE TABLE [dbo].[FIN_INTERFACE_ACCOUNT_TRANSFER] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [TRANSFER_TRX_DATE]     DATETIME        NOT NULL,
    [TRANSFER_VALUE_DATE]   DATETIME        NOT NULL,
    [TRANSFER_REMARKS]      NVARCHAR (4000) NOT NULL,
    [TRANSFER_SOURCE_NO]    NVARCHAR (50)   NOT NULL,
    [TRANSFER_SOURCE]       NVARCHAR (250)  NOT NULL,
    [TRANSFER_STATUS]       NVARCHAR (10)   NOT NULL,
    [FROM_BRANCH_CODE]      NVARCHAR (50)   NULL,
    [FROM_BRANCH_NAME]      NVARCHAR (250)  NULL,
    [FROM_CURRENCY_CODE]    NVARCHAR (3)    NULL,
    [FROM_EXCH_RATE]        DECIMAL (18, 6) NOT NULL,
    [FROM_ORIG_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [FROM_BRANCH_BANK_CODE] NVARCHAR (50)   NULL,
    [FROM_BRANCH_BANK_NAME] NVARCHAR (250)  NULL,
    [FROM_GL_LINK_CODE]     NVARCHAR (50)   NULL,
    [TO_BRANCH_CODE]        NVARCHAR (50)   NULL,
    [TO_BRANCH_NAME]        NVARCHAR (250)  NULL,
    [TO_CURRENCY_CODE]      NVARCHAR (3)    NULL,
    [TO_EXCH_RATE]          DECIMAL (18, 6) NOT NULL,
    [TO_ORIG_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [TO_BRANCH_BANK_CODE]   NVARCHAR (50)   NULL,
    [TO_BRANCH_BANK_NAME]   NVARCHAR (250)  NULL,
    [TO_GL_LINK_CODE]       NVARCHAR (50)   NULL,
    [JOB_STATUS]            NVARCHAR (10)   NOT NULL,
    [FAILED_REMARKS]        NVARCHAR (4000) NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TRANSFER_TRX_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tanggal pengakuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TRANSFER_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TRANSFER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'FROM_GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank tujuan pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang yang melakukan proses transfer pada proses account transfer tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_ACCOUNT_TRANSFER', @level2type = N'COLUMN', @level2name = N'TO_GL_LINK_CODE';

