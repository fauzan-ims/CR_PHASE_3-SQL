CREATE TABLE [dbo].[REPOSSESSION_LETTER_COLLATERAL] (
    [ID]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [LETTER_CODE]     NVARCHAR (50) NOT NULL,
    [ASSET_NO]        NVARCHAR (50) NULL,
    [IS_SUCCESS_REPO] NVARCHAR (1)  CONSTRAINT [DF_REPOSSESSION_LETTER_COLLATERAL_IS_SUCCESS] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]        DATETIME      NOT NULL,
    [CRE_BY]          NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15) NOT NULL,
    [MOD_DATE]        DATETIME      NOT NULL,
    [MOD_BY]          NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_REPOSSESSION_LETTER_COLLATERAL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_REPOSSESSION_LETTER_COLLATERAL_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]),
    CONSTRAINT [FK_REPOSSESSION_LETTER_COLLATERAL_REPOSSESSION_LETTER] FOREIGN KEY ([LETTER_CODE]) REFERENCES [dbo].[REPOSSESSION_LETTER] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER_COLLATERAL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode surat pada surat tarik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER_COLLATERAL', @level2type = N'COLUMN', @level2name = N'LETTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah collateral tersebut berhasil dilakukan proses penarikan?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_LETTER_COLLATERAL', @level2type = N'COLUMN', @level2name = N'IS_SUCCESS_REPO';

