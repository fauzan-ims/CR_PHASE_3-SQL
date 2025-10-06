CREATE TABLE [dbo].[MIGRASI_SPBPKB_1_DETAIL] (
    [ASSET_NO]           NVARCHAR (50) NULL,
    [STATUS]             NCHAR (10)    NULL,
    [REPLACEMENT_CODE]   NVARCHAR (50) NULL,
    [DOCUMENT_MAIN_CODE] NVARCHAR (50) NULL,
    [CRE_BY]             NVARCHAR (15) NULL,
    [CRE_DATE]           DATETIME      NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15) NULL,
    [MOD_BY]             NVARCHAR (15) NULL,
    [MOD_DATE]           DATETIME      NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15) NULL,
    [MIGRATION_ID]       BIGINT        NULL,
    [COVER_NOTE_NO]      NVARCHAR (50) NULL
);

