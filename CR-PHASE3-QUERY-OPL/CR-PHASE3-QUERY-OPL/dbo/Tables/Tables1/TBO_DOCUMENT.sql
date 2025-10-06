CREATE TABLE [dbo].[TBO_DOCUMENT] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [APPLICATION_NO]        NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NULL,
    [AGREEMENT_EXTERNAL_NO] NVARCHAR (50)   NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [STATUS]                NVARCHAR (15)   NULL,
    [TRANSACTION_NAME]      NVARCHAR (250)  NULL,
    [TRANSACTION_NO]        NVARCHAR (50)   NULL,
    [TRANSACTION_DATE]      DATETIME        NULL,
    [REMARKS]               NVARCHAR (4000) NULL,
    CONSTRAINT [PK_TBO_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC)
);

