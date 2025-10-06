CREATE TABLE [dbo].[SUPPLIER_SELECTION_DOCUMENT] (
    [ID]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [SUPPLIER_SELECTION_CODE] NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DOCUMENT_CODE]           NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FILE_PATH]               NVARCHAR (250)  CONSTRAINT [DF_SUPPLIER_SELECTION_DOCUMENT_FILE_PATH] DEFAULT ('') NULL,
    [FILE_NAME]               NVARCHAR (250)  CONSTRAINT [DF_SUPPLIER_SELECTION_DOCUMENT_FILE_NAME] DEFAULT ('') NULL,
    [REMARK]                  NVARCHAR (4000) CONSTRAINT [DF_SUPPLIER_SELECTION_DOCUMENT_REMARK] DEFAULT ('') NULL,
    [REFF_NO]                 NVARCHAR (50)   NULL,
    [CRE_DATE]                DATETIME        NOT NULL,
    [CRE_BY]                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                DATETIME        NOT NULL,
    [MOD_BY]                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUPPLIER_SELECTION_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE QUOTATION REVIEW', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'SUPPLIER_SELECTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DOKUMEN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALAMAT FILE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_PATH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA FILE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'REMARK';

