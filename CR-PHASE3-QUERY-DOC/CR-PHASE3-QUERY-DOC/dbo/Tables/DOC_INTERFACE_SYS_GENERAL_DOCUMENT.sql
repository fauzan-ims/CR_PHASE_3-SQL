CREATE TABLE [dbo].[DOC_INTERFACE_SYS_GENERAL_DOCUMENT] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]           NVARCHAR (50)   NOT NULL,
    [DOCUMENT_NAME]  NVARCHAR (250)  NOT NULL,
    [JOB_STATUS]     NVARCHAR (20)   CONSTRAINT [DF_DOC_INTERFACE_SYS_GENERAL_DOCUMENT_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARKS] NVARCHAR (4000) NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOC_INTERFACE_SYS_GENERAL_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_SYS_GENERAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_SYS_GENERAL_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_NAME';

