CREATE TABLE [dbo].[DOC_INTERFACE_DOCUMENT_PENDING] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NOT NULL,
    [INITIAL_BRANCH_CODE] NVARCHAR (50)   NULL,
    [INITIAL_BRANCH_NAME] NVARCHAR (250)  NULL,
    [DOCUMENT_TYPE]       NVARCHAR (20)   NULL,
    [DOCUMENT_STATUS]     NVARCHAR (250)  CONSTRAINT [DF_DOC_INTERFACE_DOCUMENT_PENDING_DOCUMENT_STATUS] DEFAULT (N'OUT LOCKER') NULL,
    [ASSET_NO]            NVARCHAR (50)   NULL,
    [ASSET_NAME]          NVARCHAR (250)  NULL,
    [COVER_NOTE_NO]       NVARCHAR (50)   NULL,
    [COVER_NOTE_DATE]     DATETIME        NULL,
    [COVER_NOTE_EXP_DATE] DATETIME        NULL,
    [FILE_NAME]           NVARCHAR (250)  NULL,
    [FILE_PATH]           NVARCHAR (250)  NULL,
    [ENTRY_DATE]          DATETIME        NULL,
    [JOB_STATUS]          NVARCHAR (20)   CONSTRAINT [DF_DOC_INTERFACE_DOCUMENT_PENDING_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARK]       NVARCHAR (4000) NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOC_INTERFACE_DOCUMENT_PENDING_1] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data interface document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data interface document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data interface document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general document pada data interface document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'INITIAL_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'INITIAL_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada data document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'DOCUMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status document pada data interface document pending tersebut - ALL, menginformasikan bahwa sistem menampilkan semua status yang ada pada proses interface document pending tersebut - HOLD, menginformasikan bahwa data document pending tersebut belum diproses - POST, menginformasikan bahwa data document pending tersebut telah dilakukan proses posting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'DOCUMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada data document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal data document pending tersebut diproses', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'ENTRY_DATE';

