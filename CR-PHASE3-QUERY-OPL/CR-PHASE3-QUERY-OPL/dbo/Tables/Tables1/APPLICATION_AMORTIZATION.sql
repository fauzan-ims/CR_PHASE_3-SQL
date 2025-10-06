CREATE TABLE [dbo].[APPLICATION_AMORTIZATION] (
    [APPLICATION_NO] NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO] INT             NOT NULL,
    [ASSET_NO]       NVARCHAR (50)   NOT NULL,
    [DUE_DATE]       DATETIME        NOT NULL,
    [BILLING_DATE]   DATETIME        NOT NULL,
    [BILLING_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_AMORTIZATION_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DESCRIPTION]    NVARCHAR (4000) CONSTRAINT [DF_APPLICATION_AMORTIZATION_DESCRIPTION] DEFAULT ('') NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_APPLICATION_AMORTIZATION] PRIMARY KEY CLUSTERED ([APPLICATION_NO] ASC, [INSTALLMENT_NO] ASC, [ASSET_NO] ASC),
    CONSTRAINT [FK_APPLICATION_AMORTIZATION_APPLICATION_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[APPLICATION_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_APPLICATION_AMORTIZATION_APPLICATION_MAIN] FOREIGN KEY ([APPLICATION_NO]) REFERENCES [dbo].[APPLICATION_MAIN] ([APPLICATION_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_AMORTIZATION', @level2type = N'COLUMN', @level2name = N'APPLICATION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_AMORTIZATION', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal jatuh tempo pembayaran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_AMORTIZATION', @level2type = N'COLUMN', @level2name = N'DUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai angsuran yang dibayarkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_AMORTIZATION', @level2type = N'COLUMN', @level2name = N'BILLING_AMOUNT';

