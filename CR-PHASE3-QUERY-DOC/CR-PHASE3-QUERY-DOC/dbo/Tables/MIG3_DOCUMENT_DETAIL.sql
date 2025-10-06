CREATE TABLE [dbo].[MIG3_DOCUMENT_DETAIL] (
    [DOCUMENT_CODE]        NVARCHAR (50)   NULL,
    [DOCUMENT_NAME]        NVARCHAR (250)  NULL,
    [DOCUMENT_TYPE]        NVARCHAR (250)  NULL,
    [DOCUMENT_DATE]        DATETIME        NULL,
    [DOCUMENT_DESCRIPTION] NVARCHAR (4000) NULL,
    [MODULE]               NVARCHAR (50)   NULL,
    [DOC_NO]               NVARCHAR (50)   NULL,
    [DOC_NAME]             NVARCHAR (250)  NULL,
    [FILE_NAME]            NVARCHAR (250)  NULL,
    [PATHS]                NVARCHAR (250)  NULL,
    [DOC_FILE]             VARBINARY (MAX) NULL,
    [EXPIRED_DATE]         DATETIME        NULL,
    [IS_TEMPORARY]         NVARCHAR (1)    NULL,
    [IS_MANUAL]            NVARCHAR (1)    NULL,
    [CRE_DATE]             DATETIME        NULL,
    [CRE_BY]               NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NULL,
    [MOD_DATE]             DATETIME        NULL,
    [MOD_BY]               NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NULL
);

