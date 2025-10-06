CREATE TABLE [dbo].[BANK_MUTATION_HISTORY] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [BANK_MUTATION_CODE] NVARCHAR (50)   NOT NULL,
    [TRANSACTION_DATE]   DATETIME        NOT NULL,
    [VALUE_DATE]         DATETIME        NOT NULL,
    [SOURCE_REFF_CODE]   NVARCHAR (50)   NULL,
    [SOURCE_REFF_NAME]   NVARCHAR (250)  NULL,
    [ORIG_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [ORIG_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]          DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [IS_RECONCILE]       NVARCHAR (1)    NOT NULL,
    [REMARKS]            NVARCHAR (4000) NOT NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    CONSTRAINT [FK_BANK_MUTATION_HISTORY_BANK_MUTATION] FOREIGN KEY ([BANK_MUTATION_CODE]) REFERENCES [dbo].[BANK_MUTATION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_JOB_JOURNAL_REPORT_NOTIFICATION_20230102]
    ON [dbo].[BANK_MUTATION_HISTORY]([BANK_MUTATION_CODE] ASC)
    INCLUDE([SOURCE_REFF_CODE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'BANK_MUTATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'TRANSACTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode referensi source pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'SOURCE_REFF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi source pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'SOURCE_REFF_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original deposit pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses deposit history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION_HISTORY', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';

