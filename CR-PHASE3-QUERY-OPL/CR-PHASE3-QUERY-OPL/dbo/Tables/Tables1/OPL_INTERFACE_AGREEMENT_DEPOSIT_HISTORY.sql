CREATE TABLE [dbo].[OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [AGREEMENT_DEPOSIT_CODE] NVARCHAR (50)   NULL,
    [AGREEMENT_NO]           NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]           NVARCHAR (15)   NOT NULL,
    [TRANSACTION_DATE]       DATETIME        NOT NULL,
    [ORIG_AMOUNT]            DECIMAL (18, 2) NOT NULL,
    [ORIG_CURRENCY_CODE]     NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]              DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]            DECIMAL (18, 2) NOT NULL,
    [PLAFOND_NO]             NVARCHAR (50)   NULL,
    [SOURCE_REFF_MODULE]     NVARCHAR (50)   NOT NULL,
    [SOURCE_REFF_CODE]       NVARCHAR (50)   NOT NULL,
    [SOURCE_REFF_NAME]       NVARCHAR (250)  NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [JOB_STATUS]             NVARCHAR (20)   NOT NULL,
    [FAILED_REMARK]          NVARCHAR (4000) NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'AGREEMENT_DEPOSIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'TRANSACTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode referensi source pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'SOURCE_REFF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi source pada data agreement deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', @level2type = N'COLUMN', @level2name = N'SOURCE_REFF_NAME';

