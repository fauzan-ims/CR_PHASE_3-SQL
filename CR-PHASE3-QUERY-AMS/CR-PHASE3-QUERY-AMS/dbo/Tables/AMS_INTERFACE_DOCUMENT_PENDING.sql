CREATE TABLE [dbo].[AMS_INTERFACE_DOCUMENT_PENDING] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [CODE]                NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250) NOT NULL,
    [INITIAL_BRANCH_CODE] NVARCHAR (50)  NULL,
    [INITIAL_BRANCH_NAME] NVARCHAR (250) NULL,
    [DOCUMENT_TYPE]       NVARCHAR (20)  NOT NULL,
    [DOCUMENT_STATUS]     NVARCHAR (10)  CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_PENDING_DOCUMENT_STATUS] DEFAULT (N'OUT LOCKER') NOT NULL,
    [CLIENT_NO]           NVARCHAR (50)  NULL,
    [CLIENT_NAME]         NVARCHAR (250) NULL,
    [ASSET_NO]            NVARCHAR (50)  NULL,
    [ASSET_NAME]          NVARCHAR (250) NULL,
    [PLAT_NO]             NVARCHAR (50)  NULL,
    [CHASIS_NO]           NVARCHAR (50)  NULL,
    [ENGINE_NO]           NVARCHAR (50)  NULL,
    [VENDOR_CODE]         NVARCHAR (50)  NULL,
    [VENDOR_NAME]         NVARCHAR (250) NULL,
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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada data document pending tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_PENDING', @level2type = N'COLUMN', @level2name = N'CLIENT_NO';

