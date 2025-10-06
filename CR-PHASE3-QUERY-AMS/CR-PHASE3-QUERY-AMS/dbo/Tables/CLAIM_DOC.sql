CREATE TABLE [dbo].[CLAIM_DOC] (
    [ID]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [CLAIM_CODE]       NVARCHAR (50)   NOT NULL,
    [DOCUMENT_CODE]    NVARCHAR (50)   NOT NULL,
    [DOCUMENT_NAME]    NVARCHAR (250)  NOT NULL,
    [DOCUMENT_DATE]    DATETIME        NULL,
    [DOCUMENT_REMARKS] NVARCHAR (4000) NOT NULL,
    [FILE_NAME]        NVARCHAR (250)  NULL,
    [PATHS]            NVARCHAR (250)  NULL,
    [IS_REQUIRED]      NVARCHAR (1)    CONSTRAINT [DF_CLAIM_DOC_IS_REQUIRED] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_CLAIM_DOC] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CLAIM_DOC_CLAIM_DOC] FOREIGN KEY ([CLAIM_CODE]) REFERENCES [dbo].[CLAIM_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode claim pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'CLAIM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'DOCUMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dokumen pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'DOCUMENT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'DOCUMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah dokumen tersebut bersifat mandatory?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_DOC', @level2type = N'COLUMN', @level2name = N'IS_REQUIRED';

