CREATE TABLE [dbo].[DOCUMENT_STORAGE_DETAIL] (
    [ID]                    BIGINT        IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_STORAGE_CODE] NVARCHAR (50) NOT NULL,
    [DOCUMENT_CODE]         NVARCHAR (50) NOT NULL,
    [CRE_DATE]              DATETIME      NOT NULL,
    [CRE_BY]                NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    [MOD_DATE]              DATETIME      NOT NULL,
    [MOD_BY]                NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    CONSTRAINT [FK_DOCUMENT_STORAGE_DETAIL_DOCUMENT_MAIN] FOREIGN KEY ([DOCUMENT_CODE]) REFERENCES [dbo].[DOCUMENT_MAIN] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_STORAGE_DETAIL_DOCUMENT_STORAGE] FOREIGN KEY ([DOCUMENT_STORAGE_CODE]) REFERENCES [dbo].[DOCUMENT_STORAGE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode penyimpanan dokumen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_STORAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen yang dilakukan proses storage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';

