CREATE TABLE [dbo].[XXX_REPLACEMENT_REQUEST_DETAIL_20240416] (
    [ID]                     BIGINT        IDENTITY (1, 1) NOT NULL,
    [REPLACEMENT_REQUEST_ID] BIGINT        NULL,
    [ASSET_NO]               NVARCHAR (50) NULL,
    [STATUS]                 NCHAR (10)    NULL,
    [REPLACEMENT_CODE]       NVARCHAR (50) NULL,
    [DOCUMENT_MAIN_CODE]     NVARCHAR (50) NULL,
    [CRE_BY]                 NVARCHAR (15) NOT NULL,
    [CRE_DATE]               DATETIME      NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15) NOT NULL,
    [MOD_BY]                 NVARCHAR (15) NOT NULL,
    [MOD_DATE]               DATETIME      NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15) NOT NULL,
    [MIGRATION_ID]           BIGINT        NULL,
    [COVER_NOTE_NO]          NVARCHAR (50) NULL
);

