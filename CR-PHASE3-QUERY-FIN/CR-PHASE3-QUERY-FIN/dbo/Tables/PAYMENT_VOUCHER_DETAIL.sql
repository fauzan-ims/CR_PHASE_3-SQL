CREATE TABLE [dbo].[PAYMENT_VOUCHER_DETAIL] (
    [ID]                   INT             IDENTITY (1, 1) NOT NULL,
    [PAYMENT_VOUCHER_CODE] NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]          NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]          NVARCHAR (250)  NOT NULL,
    [GL_LINK_CODE]         NVARCHAR (50)   NOT NULL,
    [ORIG_AMOUNT]          DECIMAL (18, 2) NOT NULL,
    [ORIG_CURRENCY_CODE]   NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]            DECIMAL (18, 2) CONSTRAINT [DF_PAYMENT_VOUCHER_DETAIL_EXCH_RATE] DEFAULT ((0)) NOT NULL,
    [BASE_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_PAYMENT_VOUCHER_DETAIL_BASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DIVISION_CODE]        NVARCHAR (50)   NULL,
    [DIVISION_NAME]        NVARCHAR (250)  NULL,
    [DEPARTMENT_CODE]      NVARCHAR (50)   NULL,
    [DEPARTMENT_NAME]      NVARCHAR (250)  NULL,
    [REMARKS]              NVARCHAR (4000) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [DOC_REFF_NO]          NVARCHAR (50)   NULL,
    CONSTRAINT [PK_PAYMENT_VOUCHER_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PAYMENT_VOUCHER_DETAIL_PAYMENT_VOUCHER] FOREIGN KEY ([PAYMENT_VOUCHER_CODE]) REFERENCES [dbo].[PAYMENT_VOUCHER] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode payment voucher pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'PAYMENT_VOUCHER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general ledger pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi original pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi payment voucher setelah dikalikan dengan nilai tukar mata uang pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode divisi pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'DIVISION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama divisi pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'DIVISION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode department pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama department pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data payment voucher detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAYMENT_VOUCHER_DETAIL', @level2type = N'COLUMN', @level2name = N'REMARKS';

