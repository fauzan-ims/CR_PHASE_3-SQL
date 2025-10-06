CREATE TABLE [dbo].[MASTER_INSURANCE_DOCUMENT] (
    [ID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [INSURANCE_CODE] NVARCHAR (50)  NOT NULL,
    [DOCUMENT_CODE]  NVARCHAR (50)  NOT NULL,
    [DOCUMENT_NAME]  NVARCHAR (250) NULL,
    [FILE_NAME]      NVARCHAR (250) NULL,
    [PATHS]          NVARCHAR (250) NULL,
    [DOC_FILE]       IMAGE          NULL,
    [EXPIRED_DATE]   DATETIME       NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_INSURANCE_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_INSURANCE_DOCUMENT_MASTER_INSURANCE] FOREIGN KEY ([INSURANCE_CODE]) REFERENCES [dbo].[MASTER_INSURANCE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode maskapai asuransi atas data master insurance document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'INSURANCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen atas data master insurance document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data master insurance document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file dokumen yang diupload kedalam sistem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder dari file dokumen yang diupload kedalam sistem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOC_FILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa atas data dokumen yang telah diupload', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_DOCUMENT', @level2type = N'COLUMN', @level2name = N'EXPIRED_DATE';

