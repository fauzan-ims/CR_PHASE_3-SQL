CREATE TABLE [dbo].[CASHIER_BANKNOTE_AND_COIN] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [CASHIER_CODE]   NVARCHAR (50)   NOT NULL,
    [BANKNOTE_CODE]  NVARCHAR (50)   NOT NULL,
    [QUANTITY]       INT             NOT NULL,
    [TOTAL_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_BANKNOTE_AND_COIN_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CASHIER_BANKNOTE_AND_COIN] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CASHIER_BANKNOTE_AND_COIN_CASHIER_MAIN] FOREIGN KEY ([CASHIER_CODE]) REFERENCES [dbo].[CASHIER_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_CASHIER_BANKNOTE_AND_COIN_MASTER_BANKNOTE_AND_COIN] FOREIGN KEY ([BANKNOTE_CODE]) REFERENCES [dbo].[MASTER_BANKNOTE_AND_COIN] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_BANKNOTE_AND_COIN', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cashier pada data cashier banknote and coin tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_BANKNOTE_AND_COIN', @level2type = N'COLUMN', @level2name = N'CASHIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode banknote pada data cashier banknote and coin tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_BANKNOTE_AND_COIN', @level2type = N'COLUMN', @level2name = N'BANKNOTE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kuantitas pada data cashier banknote and coin tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_BANKNOTE_AND_COIN', @level2type = N'COLUMN', @level2name = N'QUANTITY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total pada data cashier banknote and coin tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_BANKNOTE_AND_COIN', @level2type = N'COLUMN', @level2name = N'TOTAL_AMOUNT';

