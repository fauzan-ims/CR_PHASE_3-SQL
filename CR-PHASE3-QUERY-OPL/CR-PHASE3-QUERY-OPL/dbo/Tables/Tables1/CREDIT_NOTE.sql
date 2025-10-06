CREATE TABLE [dbo].[CREDIT_NOTE] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]      NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]      NVARCHAR (250)  NOT NULL,
    [DATE]             DATETIME        NOT NULL,
    [STATUS]           NVARCHAR (10)   NOT NULL,
    [REMARK]           NVARCHAR (4000) NOT NULL,
    [INVOICE_NO]       NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]    NVARCHAR (3)    NOT NULL,
    [BILLING_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_TOTAL_BILLING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_TOTAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPN_PCT]          DECIMAL (9, 6)  NOT NULL,
    [PPN_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_TOTAL_PPN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPH_PCT]          DECIMAL (9, 6)  NOT NULL,
    [PPH_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_TOTAL_PPH_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CREDIT_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_BILLING_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [NEW_FAKTUR_NO]    NVARCHAR (50)   NOT NULL,
    [NEW_PPN_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_PPN_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [NEW_PPH_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_PPH_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [NEW_TOTAL_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_CREDIT_NOTE_TOTAL_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [IS_FROM_ET]       NVARCHAR (1)    NULL,
    [ET_NO]            NVARCHAR (50)   NULL,
    CONSTRAINT [PK_CREDIT_NOTE] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_CREDIT_NOTE_INVOICE] FOREIGN KEY ([INVOICE_NO]) REFERENCES [dbo].[INVOICE] ([INVOICE_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total tagihan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'BILLING_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total PPN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total PPH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'PPH_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total Invoice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'TOTAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total tagihan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'CREDIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total PPN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'NEW_PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total PPH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'NEW_PPH_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total Invoice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CREDIT_NOTE', @level2type = N'COLUMN', @level2name = N'NEW_TOTAL_AMOUNT';

