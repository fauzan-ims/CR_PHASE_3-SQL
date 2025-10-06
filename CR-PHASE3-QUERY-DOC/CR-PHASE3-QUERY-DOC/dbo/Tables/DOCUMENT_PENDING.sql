CREATE TABLE [dbo].[DOCUMENT_PENDING] (
    [CODE]                NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250) NOT NULL,
    [INITIAL_BRANCH_CODE] NVARCHAR (50)  NULL,
    [INITIAL_BRANCH_NAME] NVARCHAR (250) NULL,
    [DOCUMENT_TYPE]       NVARCHAR (20)  CONSTRAINT [DF_DOCUMENT_PENDING_DOCUMENT_TYPE] DEFAULT (N'application') NOT NULL,
    [DOCUMENT_STATUS]     NVARCHAR (10)  CONSTRAINT [DF_DOCUMENT_PENDING_DOCUMENT_STATUS] DEFAULT (N'OUT LOCKER') NOT NULL,
    [ASSET_NO]            NVARCHAR (50)  NULL,
    [ASSET_NAME]          NVARCHAR (250) NULL,
    [COVER_NOTE_NO]       NVARCHAR (50)  NULL,
    [COVER_NOTE_DATE]     DATETIME       NULL,
    [COVER_NOTE_EXP_DATE] DATETIME       NULL,
    [FILE_NAME]           NVARCHAR (250) NULL,
    [FILE_PATH]           NVARCHAR (250) NULL,
    [ENTRY_DATE]          DATETIME       NULL,
    [CRE_DATE]            DATETIME       NOT NULL,
    [CRE_BY]              NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)  NOT NULL,
    [MOD_DATE]            DATETIME       NOT NULL,
    [MOD_BY]              NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_DOCUMENT_PENDING] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses dokumen pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses dokumen pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses dokumen pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang initial pada proses dokumen pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'INITIAL_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang initial pada proses dokumen pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'INITIAL_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe dokumen pada proses dokumen pending tersebut - COLLATERAL, menginformasikan bahwa dokumen tersebut merupakan dokumen collateral - LEGAL, menginformasikan bahwa dokumen tersebut merupakan dokumen legal - INSURANCE, menginformasikan bahwa dokumen tersebut merupakan dokumen asuransi - OTHER, menginformasikan bahwa dokumen tersebut merupakan dokumen lain lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'DOCUMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses dokumen pending tersebut - HOLD,menginformasikan bahwa data dokumen pending tersebut belum diproses - POST, menginformasikan bahwa data dokumen pending tersebut sudah dilakukan proses posting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'DOCUMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada proses dokumen pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'ASSET_NAME';

