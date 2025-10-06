CREATE TABLE [dbo].[MIG_DOCUMENT_DETAIL_14112023] (
    [DOCUMENT_CODE]        NVARCHAR (50)  NULL,
    [DOCUMENT_NAME]        NVARCHAR (250) NULL,
    [DOCUMENT_TYPE]        NVARCHAR (50)  NULL,
    [DOCUMENT_DATE]        DATETIME       NULL,
    [DOCUMENT_DESCRIPTION] NVARCHAR (250) NULL,
    [MODULE]               NVARCHAR (50)  NULL,
    [DOC_NO]               NVARCHAR (50)  NULL,
    [DOC_NAME]             NVARCHAR (250) NULL,
    [FILE_NAME]            NVARCHAR (50)  NULL,
    [PATHS]                NVARCHAR (50)  NULL,
    [DOC_FILE]             NVARCHAR (50)  NULL,
    [EXPIRED_DATE]         DATETIME       NULL,
    [IS_TEMPORARY]         NVARCHAR (1)   NULL,
    [IS_MANUAL]            NVARCHAR (1)   NULL
);

