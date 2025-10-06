CREATE TABLE [dbo].[DEPOSIT_ALLOCATION_DETAIL] (
    [ID]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [DEPOSIT_ALLOCATION_CODE] NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]        NVARCHAR (50)   NULL,
    [RECEIVED_REQUEST_CODE]   NVARCHAR (50)   NULL,
    [IS_PAID]                 NVARCHAR (1)    NOT NULL,
    [INNITIAL_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [ORIG_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_DEPOSIT_ALLOCATION_DETAIL_ORIG_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ORIG_CURRENCY_CODE]      NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]               DECIMAL (18, 6) CONSTRAINT [DF_DEPOSIT_ALLOCATION_DETAIL_EXCH_RATE] DEFAULT ((0)) NOT NULL,
    [BASE_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_DEPOSIT_ALLOCATION_DETAIL_BASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INSTALLMENT_NO]          INT             NULL,
    [REMARKS]                 NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                DATETIME        NOT NULL,
    [CRE_BY]                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                DATETIME        NOT NULL,
    [MOD_BY]                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DEPOSIT_ALLOCATION_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEPOSIT_ALLOCATION_DETAIL_CASHIER_RECEIVED_REQUEST] FOREIGN KEY ([RECEIVED_REQUEST_CODE]) REFERENCES [dbo].[CASHIER_RECEIVED_REQUEST] ([CODE]),
    CONSTRAINT [FK_DEPOSIT_ALLOCATION_DETAIL_DEPOSIT_ALLOCATION] FOREIGN KEY ([DEPOSIT_ALLOCATION_CODE]) REFERENCES [dbo].[DEPOSIT_ALLOCATION] ([CODE]),
    CONSTRAINT [FK_DEPOSIT_ALLOCATION_DETAIL_MASTER_TRANSACTION] FOREIGN KEY ([TRANSACTION_CODE]) REFERENCES [dbo].[MASTER_TRANSACTION] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_DEPOSIT_ALLOCATION_DETAIL_DEPOSIT_ALLOCATION_CODE_IS_PAID_20250718]
    ON [dbo].[DEPOSIT_ALLOCATION_DETAIL]([DEPOSIT_ALLOCATION_CODE] ASC, [IS_PAID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode alokasi deposit pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_ALLOCATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaksi pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request penerimaan pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data alokasi deposit tersebut sudah dilakukan proses pembayaran?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_PAID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai alokasi original pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'REMARKS';

