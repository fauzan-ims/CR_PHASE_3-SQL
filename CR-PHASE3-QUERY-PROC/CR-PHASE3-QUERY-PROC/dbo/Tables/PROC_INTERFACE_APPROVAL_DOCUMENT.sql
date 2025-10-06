CREATE TABLE [dbo].[PROC_INTERFACE_APPROVAL_DOCUMENT] (
    [ID]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [REQUEST_CODE]     NVARCHAR (50)   NOT NULL,
    [DOCUMENT_CODE]    NVARCHAR (20)   NOT NULL,
    [DOCUMENT_REMARKS] NVARCHAR (4000) NULL,
    [FILE_NAME]        NVARCHAR (250)  NULL,
    [PATHS]            NVARCHAR (250)  NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_PROC_INTERFACE_APPROVAL_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data dokumen Prospect tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROC_INTERFACE_APPROVAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode BAST pada data dokumen Prospect tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROC_INTERFACE_APPROVAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen pada data dokumen Prospect tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROC_INTERFACE_APPROVAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data dokumen Prospect tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROC_INTERFACE_APPROVAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada data dokumen Prospect tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROC_INTERFACE_APPROVAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada data dokumen Prospect tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROC_INTERFACE_APPROVAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'PATHS';

