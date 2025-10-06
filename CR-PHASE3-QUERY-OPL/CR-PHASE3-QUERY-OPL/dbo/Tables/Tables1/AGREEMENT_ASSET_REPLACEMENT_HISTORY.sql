CREATE TABLE [dbo].[AGREEMENT_ASSET_REPLACEMENT_HISTORY] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ASSET_NO]             NVARCHAR (50)  NOT NULL,
    [NEW_FIXED_ASSET_CODE] NVARCHAR (50)  NOT NULL,
    [NEW_FIXED_ASSET_NAME] NVARCHAR (250) NOT NULL,
    [REPLACEMENT_CODE]     NVARCHAR (50)  NOT NULL,
    [REPLACEMENT_DATE]     DATETIME       NOT NULL,
    [IS_LATEST]            NVARCHAR (1)   NOT NULL,
    [CRE_DATE]             DATETIME       NOT NULL,
    [CRE_BY]               NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)  NOT NULL,
    [MOD_DATE]             DATETIME       NOT NULL,
    [MOD_BY]               NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_AGREEMENT_ASSET_REPLACEMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_AGREEMENT_ASSET_REPLACEMENT_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_REPLACEMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_REPLACEMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'NEW_FIXED_ASSET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_REPLACEMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'NEW_FIXED_ASSET_NAME';

