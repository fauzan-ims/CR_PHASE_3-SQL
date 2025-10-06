CREATE TABLE [dbo].[APPLICATION_ASSET_DOC] (
    [ID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [ASSET_NO]       NVARCHAR (50)  NOT NULL,
    [DOCUMENT_CODE]  NVARCHAR (50)  NOT NULL,
    [FILENAME]       NVARCHAR (250) NOT NULL,
    [PATHS]          NVARCHAR (250) NOT NULL,
    [EXPIRED_DATE]   DATETIME       NULL,
    [PROMISE_DATE]   DATETIME       NULL,
    [IS_REQUIRED]    NVARCHAR (1)   NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_APPLICATION_ASSET_DOC] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_APPLICATION_ASSET_DOC_APPLICATION_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[APPLICATION_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_APPLICATION_ASSET_DOC_SYS_GENERAL_DOCUMENT] FOREIGN KEY ([DOCUMENT_CODE]) REFERENCES [dbo].[SYS_GENERAL_DOCUMENT] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto Generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'FILENAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa dokumen asset ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'EXPIRED_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal client berjanji untuk melengkapi dokumen asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'PROMISE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah dokumen tersebut bersifat wajib dipenuhi?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_DOC', @level2type = N'COLUMN', @level2name = N'IS_REQUIRED';

