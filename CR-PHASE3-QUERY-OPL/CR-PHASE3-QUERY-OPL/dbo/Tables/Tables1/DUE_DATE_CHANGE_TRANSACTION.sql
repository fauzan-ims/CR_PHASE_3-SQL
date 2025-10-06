CREATE TABLE [dbo].[DUE_DATE_CHANGE_TRANSACTION] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DUE_DATE_CHANGE_CODE] NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]     NVARCHAR (50)   NOT NULL,
    [TRANSACTION_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_CHANGE_DUE_DATE_TRANSACTION_TRANSACTION_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISC_PCT]             DECIMAL (9, 6)  NOT NULL,
    [DISC_AMOUNT]          DECIMAL (18, 2) NOT NULL,
    [TOTAL_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [ORDER_KEY]            INT             CONSTRAINT [DF_DUE_DATE_CHANGE_TRANSACTION_IS_TRANSACTION1] DEFAULT ((0)) NOT NULL,
    [IS_AMOUNT_EDITABLE]   NVARCHAR (1)    CONSTRAINT [DF_DUE_DATE_CHANGE_TRANSACTION_IS_AMOUNT_EDITABLE] DEFAULT ((0)) NOT NULL,
    [IS_DISCOUNT_EDITABLE] NVARCHAR (1)    NOT NULL,
    [IS_TRANSACTION]       NVARCHAR (1)    CONSTRAINT [DF_CHANGE_DUE_DATE_TRANSACTION_IS_TRANSACTION] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CHANGE_DUE_DATE_TRANSACTION] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DUE_DATE_CHANGE_TRANSACTION_DUE_DATE_CHANGE_MAIN] FOREIGN KEY ([DUE_DATE_CHANGE_CODE]) REFERENCES [dbo].[DUE_DATE_CHANGE_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_DUE_DATE_CHANGE_TRANSACTION_JOURNAL_GL_LINK] FOREIGN KEY ([TRANSACTION_CODE]) REFERENCES [dbo].[MASTER_TRANSACTION] ([CODE]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'DUE_DATE_CHANGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general ledger pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah nilai pada data ET transaction tersebut dapat dilakukan proses edit?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_AMOUNT_EDITABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut merupakan data transaksi atau hanya sekedar informasi saja? jika data di tickmark maka akan digunakan sebagai komponen perhitungan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_TRANSACTION';

