CREATE TABLE [dbo].[BILLING_SCHEME_DETAIL] (
    [ID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [SCHEME_CODE]    NVARCHAR (50) NOT NULL,
    [AGREEMENT_NO]   NVARCHAR (50) NOT NULL,
    [ASSET_NO]       NVARCHAR (50) NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_BILLING_SCHEME_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_BILLING_SCHEME_DETAIL_BILLING_SCHEME] FOREIGN KEY ([SCHEME_CODE]) REFERENCES [dbo].[BILLING_SCHEME] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BILLING_SCHEME_DETAIL', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BILLING_SCHEME_DETAIL', @level2type = N'COLUMN', @level2name = N'ASSET_NO';

