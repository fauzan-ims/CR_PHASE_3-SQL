CREATE TABLE [dbo].[PROCUREMENT_REQUEST_DOCUMENT] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [PROCUREMENT_REQUEST_CODE] NVARCHAR (50)   NOT NULL,
    [FILE_PATH]                NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_DOCUMENT_FILE_PATH] DEFAULT ('') NULL,
    [FILE_NAME]                NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_DOCUMENT_FILE_NAME] DEFAULT ('') NULL,
    [REMARK]                   NVARCHAR (4000) CONSTRAINT [DF_PROCUREMENT_REQUEST_DOCUMENT_REMARK] DEFAULT ('') NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_PROCUREMENT_REQUEST_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PROCUREMENT_REQUEST_DOCUMENT_PROCUREMENT_REQUEST] FOREIGN KEY ([PROCUREMENT_REQUEST_CODE]) REFERENCES [dbo].[PROCUREMENT_REQUEST] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_DOCUMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PROCURMENT_REQUEST', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_DOCUMENT', @level2type = N'COLUMN', @level2name = N'PROCUREMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALAMAT FILE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_PATH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA FILE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_DOCUMENT', @level2type = N'COLUMN', @level2name = N'REMARK';

