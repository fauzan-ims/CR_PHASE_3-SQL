CREATE TABLE [dbo].[WRITE_OFF_TRANSACTION] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [WO_CODE]              NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]     NVARCHAR (50)   NOT NULL,
    [TRANSACTION_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [IS_AMOUNT_EDITABLE]   NVARCHAR (1)    CONSTRAINT [DF_WRITE_OFF_TRANSACTION_IS_AMOUNT_EDITABLE] DEFAULT ((0)) NOT NULL,
    [IS_DISCOUNT_EDITABLE] NVARCHAR (1)    CONSTRAINT [DF_WRITE_OFF_TRANSACTION_IS_DISCOUNT_EDITABLE] DEFAULT ((0)) NOT NULL,
    [IS_TRANSACTION]       NVARCHAR (1)    CONSTRAINT [DF_WRITE_OFF_TRANSACTION_IS_RECEIVE_FLAG] DEFAULT ((0)) NOT NULL,
    [ORDER_KEY]            INT             NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_WRITE_OFF_TRANSACTION] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_WRITE_OFF_TRANSACTION_MASTER_TRANSACTION] FOREIGN KEY ([TRANSACTION_CODE]) REFERENCES [dbo].[MASTER_TRANSACTION] ([CODE]) ON UPDATE CASCADE,
    CONSTRAINT [FK_WRITE_OFF_TRANSACTION_WRITE_OFF_MAIN] FOREIGN KEY ([WO_CODE]) REFERENCES [dbo].[WRITE_OFF_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode write off pada data transaksi write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'WO_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general ledger pada data transaksi write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi pada data transaksi write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah nilai pada data ET transaction tersebut dapat dilakukan proses edit?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_AMOUNT_EDITABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah nilai diskon pada data ET transaction tersebut dapat di edit?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_DISCOUNT_EDITABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut merupakan sebagai informasi atau sebagai transaksi? Jika data tersebut di tickmark maka akan digunakan sebagai komponen perhitungan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_TRANSACTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut pada data transaksi write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';

