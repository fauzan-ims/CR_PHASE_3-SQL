CREATE TABLE [dbo].[XXX_DOCUMENT_STORAGE_DETAIL_16112023] (
    [ID]                    BIGINT        IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_STORAGE_CODE] NVARCHAR (50) NOT NULL,
    [DOCUMENT_CODE]         NVARCHAR (50) NOT NULL,
    [CRE_DATE]              DATETIME      NOT NULL,
    [CRE_BY]                NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    [MOD_DATE]              DATETIME      NOT NULL,
    [MOD_BY]                NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15) NOT NULL
);

