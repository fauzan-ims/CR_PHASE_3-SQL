CREATE TABLE [dbo].[DEPOSIT_RELEASE_DETAIL] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DEPOSIT_RELEASE_CODE] NVARCHAR (50)   NOT NULL,
    [DEPOSIT_CODE]         NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]         NVARCHAR (15)   NULL,
    [DEPOSIT_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_DEPOSIT_RELEASE_DETAIL_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [RELEASE_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_DEPOSIT_RELEASE_DETAIL_RELEASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DEPOSIT_RELEASE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEPOSIT_RELEASE_DETAIL_DEPOSIT_RELEASE] FOREIGN KEY ([DEPOSIT_RELEASE_CODE]) REFERENCES [dbo].[DEPOSIT_RELEASE] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode release deposit pada data deposit release detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_RELEASE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit pada data deposit release detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit pada data deposit release detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang akan direlease pada data deposit release detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE_DETAIL', @level2type = N'COLUMN', @level2name = N'RELEASE_AMOUNT';

