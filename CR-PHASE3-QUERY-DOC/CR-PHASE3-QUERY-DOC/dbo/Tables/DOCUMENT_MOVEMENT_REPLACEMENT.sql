CREATE TABLE [dbo].[DOCUMENT_MOVEMENT_REPLACEMENT] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [MOVEMENT_CODE]  NVARCHAR (50)   NOT NULL,
    [DOCUMENT_NAME]  NVARCHAR (250)  NULL,
    [DOCUMENT_NO]    NVARCHAR (50)   NULL,
    [REMARKS]        NVARCHAR (4000) NULL,
    [FILE_NAME]      NVARCHAR (250)  NULL,
    [PATHS]          NVARCHAR (250)  NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOCUMENT_MOVEMENT_REPLACEMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DOCUMENT_MOVEMENT_REPLACEMENT_DOCUMENT_MOVEMENT] FOREIGN KEY ([MOVEMENT_CODE]) REFERENCES [dbo].[DOCUMENT_MOVEMENT] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_REPLACEMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode movement pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_REPLACEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_REPLACEMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_NAME';

