CREATE TABLE [dbo].[WRITE_OFF_DETAIL] (
    [ID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [WRITE_OFF_CODE] NVARCHAR (50) NOT NULL,
    [ASSET_NO]       NVARCHAR (50) NOT NULL,
    [IS_TAKE_ASSETS] NVARCHAR (1)  NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_WRITE OFF_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode ET pada data ET detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_DETAIL', @level2type = N'COLUMN', @level2name = N'WRITE_OFF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada data ET detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_DETAIL', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut dilakukan proses terminate?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_TAKE_ASSETS';

