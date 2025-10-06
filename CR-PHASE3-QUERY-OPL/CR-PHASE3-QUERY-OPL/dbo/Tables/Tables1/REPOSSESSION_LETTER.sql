CREATE TABLE [dbo].[REPOSSESSION_LETTER] (
    [CODE]                             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                      NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                      NVARCHAR (250)  NOT NULL,
    [LETTER_STATUS]                    NVARCHAR (20)   NOT NULL,
    [LETTER_DATE]                      DATETIME        NOT NULL,
    [LETTER_NO]                        NVARCHAR (50)   NOT NULL,
    [LETTER_REMARKS]                   NVARCHAR (4000) NULL,
    [LETTER_PROCEED_BY]                NVARCHAR (1)    NULL,
    [LETTER_EXECUTOR_CODE]             NVARCHAR (50)   NULL,
    [LETTER_COLLECTOR_CODE]            NVARCHAR (50)   NULL,
    [LETTER_COLLECTOR_NAME]            NVARCHAR (250)  NULL,
    [LETTER_COLLECTOR_POSITION]        NVARCHAR (50)   NULL,
    [LETTER_SIGNER_COLLECTOR_CODE]     NVARCHAR (50)   NULL,
    [LETTER_SIGNER_COLLECTOR_NAME]     NVARCHAR (250)  NULL,
    [LETTER_SIGNER_COLLECTOR_POSITION] NVARCHAR (50)   NULL,
    [LETTER_EFF_DATE]                  DATETIME        NULL,
    [LETTER_EXP_DATE]                  DATETIME        NULL,
    [AGREEMENT_NO]                     NVARCHAR (50)   NOT NULL,
    [RENTAL_AMOUNT]                    DECIMAL (18, 2) NOT NULL,
    [RENTAL_DUE_DATE]                  DATETIME        NULL,
    [COMPANION_NAME]                   NVARCHAR (250)  NULL,
    [COMPANION_ID_NO]                  NVARCHAR (50)   NULL,
    [COMPANION_JOB]                    NVARCHAR (50)   NULL,
    [OVERDUE_PERIOD]                   INT             CONSTRAINT [DF_REPOSITION_LETTER_OVERDUE_PERIOD] DEFAULT ((0)) NULL,
    [OVERDUE_DAYS]                     INT             CONSTRAINT [DF_REPOSITION_LETTER_OVERDUE_DAYS] DEFAULT ((0)) NOT NULL,
    [OVERDUE_PENALTY_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_REPOSITION_LETTER_OVERDUE_PENALTY] DEFAULT ((0)) NOT NULL,
    [OVERDUE_INVOICE_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_REPOSITION_LETTER_OVERDUE_INSTALLMENT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_RENTAL_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_REPOSITION_LETTER_OUTSTANDING_INSTALLMENT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_DEPOSIT_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_REPOSITION_LETTER_OUTSTANDING_DEPOSIT] DEFAULT ((0)) NOT NULL,
    [RESULT_STATUS]                    NVARCHAR (10)   NULL,
    [RESULT_DATE]                      DATETIME        NULL,
    [RESULT_ACTION]                    NVARCHAR (10)   NULL,
    [SURAT_NO]                         NVARCHAR (50)   NULL,
    [CRE_DATE]                         DATETIME        NOT NULL,
    [CRE_BY]                           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                         DATETIME        NOT NULL,
    [MOD_BY]                           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_REPOSITION_LETTER] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_REPOSSESSION_LETTER_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_REPOSSESSION_LETTER_REPOSSESSION_LETTER] FOREIGN KEY ([CODE]) REFERENCES [dbo].[REPOSSESSION_LETTER] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada surat keterangan tarik tersebut - HOLD, menginformasikan bahwa data SKT tersebut belum diproses - POST, menginformasikan bahwa SKT tersebut  sudah dilakukan proses posting - CANCEL, menginformasikan bahwa SKT tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal terbitnya surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor surat pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang memproses SKT tersebut - INTERNAL, menginformasikan bahwa SKT tersebut dikirim oleh pihak internal multifinance - EXTERNAL, menginformasikan bahwa data SKT tersebut dikirim oleh pihak kurir external', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_PROCEED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode executor pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_EXECUTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode collector pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode collector yang menandatangani surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_SIGNER_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal mulai berlakunya SKT tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_EFF_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsanya SKT tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_EXP_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pihak yang mendampingi pada pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'COMPANION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor indentitas pihak yang mendampingi penarikan pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'COMPANION_ID_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pekerjaan pihak yang mendampingi penarikan pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'COMPANION_JOB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah periode keterlambatan pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'OVERDUE_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah keterlambatan hari pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'OVERDUE_DAYS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai denda keterlambatan pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'OVERDUE_PENALTY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa deposit pada surat keterangan tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal keluarnya hasil dari proses penarikan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'RESULT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER', @level2type = N'COLUMN', @level2name = N'RESULT_ACTION';

