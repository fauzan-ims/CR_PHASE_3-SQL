CREATE TABLE [dbo].[AGREEMENT_INVOICE_PPH] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]     NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]   NVARCHAR (50)   NOT NULL,
    [ASSET_NO]       NVARCHAR (50)   NOT NULL,
    [BILLING_NO]     INT             NOT NULL,
    [DUE_DATE]       DATETIME        NOT NULL,
    [INVOICE_DATE]   DATETIME        NOT NULL,
    [PPH_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_PPH_AR_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DESCRIPTION]    NVARCHAR (4000) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_INVOICE_PPH] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_AGREEMENT_INVOICE_PPH_INVOICE] FOREIGN KEY ([INVOICE_NO]) REFERENCES [dbo].[INVOICE] ([INVOICE_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_20250203_AGREEMENT_INVOICE_PPH]
    ON [dbo].[AGREEMENT_INVOICE_PPH]([AGREEMENT_NO] ASC)
    INCLUDE([ASSET_NO], [PPH_AMOUNT]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_INVOICE_PPH', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_INVOICE_PPH', @level2type = N'COLUMN', @level2name = N'BILLING_NO';

