CREATE TABLE [dbo].[XXX_DOCUMENT_DETAIL_20240219] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_CODE]        NVARCHAR (50)   NOT NULL,
    [DOCUMENT_NAME]        NVARCHAR (250)  NOT NULL,
    [DOCUMENT_TYPE]        NVARCHAR (250)  NULL,
    [DOCUMENT_DATE]        DATETIME        NULL,
    [DOCUMENT_DESCRIPTION] NVARCHAR (4000) NOT NULL,
    [MODULE]               NVARCHAR (50)   NULL,
    [DOC_NO]               NVARCHAR (50)   NULL,
    [DOC_NAME]             NVARCHAR (250)  NULL,
    [FILE_NAME]            NVARCHAR (250)  NULL,
    [PATHS]                NVARCHAR (250)  NULL,
    [DOC_FILE]             VARBINARY (MAX) NULL,
    [EXPIRED_DATE]         DATETIME        NULL,
    [IS_TEMPORARY]         NVARCHAR (1)    NOT NULL,
    [IS_MANUAL]            NVARCHAR (1)    NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

