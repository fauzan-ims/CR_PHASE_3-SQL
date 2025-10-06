CREATE TABLE [dbo].[DOCUMENT_MOVEMENT_DETAIL] (
    [ID]                    INT             IDENTITY (1, 1) NOT NULL,
    [MOVEMENT_CODE]         NVARCHAR (50)   NOT NULL,
    [DOCUMENT_CODE]         NVARCHAR (50)   NULL,
    [DOCUMENT_REQUEST_CODE] NVARCHAR (50)   NULL,
    [DOCUMENT_PENDING_CODE] NVARCHAR (50)   NULL,
    [IS_REJECT]             NVARCHAR (1)    CONSTRAINT [DF_DOCUMENT_MOVEMENT_DETAIL_IS_REJECT] DEFAULT ((0)) NULL,
    [REMARKS]               NVARCHAR (4000) NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOCUMENT_BORROW_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DOCUMENT_MUTATION_DETAIL_DOCUMENT_MAIN] FOREIGN KEY ([DOCUMENT_CODE]) REFERENCES [dbo].[DOCUMENT_MAIN] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MUTATION_DETAIL_DOCUMENT_MUTATION_DETAIL] FOREIGN KEY ([MOVEMENT_CODE]) REFERENCES [dbo].[DOCUMENT_MOVEMENT] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_DOCUMENT_MUTATION_DETAIL_DOCUMENT_PENDING] FOREIGN KEY ([DOCUMENT_PENDING_CODE]) REFERENCES [dbo].[DOCUMENT_PENDING] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MUTATION_DETAIL_DOCUMENT_REQUEST] FOREIGN KEY ([DOCUMENT_REQUEST_CODE]) REFERENCES [dbo].[DOCUMENT_REQUEST] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MOVEMENT_DETAIL_MOVEMENT_CODE_20250516]
    ON [dbo].[DOCUMENT_MOVEMENT_DETAIL]([MOVEMENT_CODE] ASC)
    INCLUDE([DOCUMENT_CODE]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MOVEMENT_DETAIL_DOCUMENT_CODE_2025015]
    ON [dbo].[DOCUMENT_MOVEMENT_DETAIL]([DOCUMENT_CODE] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode movement pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'MOVEMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen pending pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_PENDING_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data movement dokumen tersebut telah ditolak?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_REJECT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'REMARKS';

