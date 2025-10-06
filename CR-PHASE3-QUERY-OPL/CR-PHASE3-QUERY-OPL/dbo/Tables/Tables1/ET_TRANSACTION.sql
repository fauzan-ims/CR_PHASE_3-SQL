CREATE TABLE [dbo].[ET_TRANSACTION] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ET_CODE]              NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]     NVARCHAR (50)   NOT NULL,
    [TRANSACTION_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_ET_TRANSACTION_TRANSACTION_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISC_PCT]             DECIMAL (9, 6)  CONSTRAINT [DF_ET_TRANSACTION_DISC_PCT] DEFAULT ((0)) NOT NULL,
    [DISC_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_ET_TRANSACTION_DISC_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_ET_TRANSACTION_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ORDER_KEY]            INT             CONSTRAINT [DF_ET_TRANSACTION_ORDER_KEY] DEFAULT ((1)) NOT NULL,
    [IS_AMOUNT_EDITABLE]   NVARCHAR (1)    NOT NULL,
    [IS_DISCOUNT_EDITABLE] NVARCHAR (1)    CONSTRAINT [DF_ET_TRANSACTION_IS_DISCOUNT_EDITABLE] DEFAULT ((0)) NOT NULL,
    [IS_TRANSACTION]       NVARCHAR (1)    CONSTRAINT [DF_ET_TRANSACTION_IS_TRANSACTION] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]             DATETIME        CONSTRAINT [DF_ET_TRANSACTION_CRE_DATE] DEFAULT ((1)) NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ET_TRANSACTION] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ET_TRANSACTION_ET_MAIN] FOREIGN KEY ([ET_CODE]) REFERENCES [dbo].[ET_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_ET_TRANSACTION_MASTER_TRANSACTION] FOREIGN KEY ([TRANSACTION_CODE]) REFERENCES [dbo].[MASTER_TRANSACTION] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode ET pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general ledger pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai transaksi pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase diskon pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'DISC_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai diskon pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'DISC_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tranasksi dikurangi dengan nilai diskon pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TOTAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut pada data ET transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah nilai pada data ET transaction tersebut dapat dilakukan proses edit?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_AMOUNT_EDITABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah nilai diskon pada data ET transaction tersebut dapat di edit?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_DISCOUNT_EDITABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut merupakan informasi atau transaksi? jika data di tickmark, maka akan digunakan sebagai komponen perhitungan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_TRANSACTION';

