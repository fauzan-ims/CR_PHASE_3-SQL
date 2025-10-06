CREATE TABLE [dbo].[XXX_DOCUMENT_MOVEMENT_DETAIL_16112023] (
    [ID]                    INT             IDENTITY (1, 1) NOT NULL,
    [MOVEMENT_CODE]         NVARCHAR (50)   NOT NULL,
    [DOCUMENT_CODE]         NVARCHAR (50)   NULL,
    [DOCUMENT_REQUEST_CODE] NVARCHAR (50)   NULL,
    [DOCUMENT_PENDING_CODE] NVARCHAR (50)   NULL,
    [IS_REJECT]             NVARCHAR (1)    NULL,
    [REMARKS]               NVARCHAR (4000) NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL
);

