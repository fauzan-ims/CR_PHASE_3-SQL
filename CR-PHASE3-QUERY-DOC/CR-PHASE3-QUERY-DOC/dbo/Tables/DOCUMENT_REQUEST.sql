CREATE TABLE [dbo].[DOCUMENT_REQUEST] (
    [CODE]                       NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                NVARCHAR (250)  NOT NULL,
    [REQUEST_TYPE]               NVARCHAR (20)   CONSTRAINT [DF_DOCUMENT_REQUEST_MUTATION_TYPE] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_LOCATION]           NVARCHAR (20)   CONSTRAINT [DF_DOCUMENT_REQUEST_MUTATION_LOCATION] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_FROM]               NVARCHAR (50)   CONSTRAINT [DF_DOCUMENT_REQUEST_MUTATION_FROM] DEFAULT (N'OUT LOCKER') NULL,
    [REQUEST_TO]                 NVARCHAR (50)   CONSTRAINT [DF_DOCUMENT_REQUEST_MUTATION_TO] DEFAULT (N'OUT LOCKER') NULL,
    [REQUEST_TO_AGREEMENT_NO]    NVARCHAR (50)   NULL,
    [REQUEST_TO_CLIENT_NAME]     NVARCHAR (250)  CONSTRAINT [DF_DOCUMENT_REQUEST_MOVEMENT_TO_CLIENT_NAME] DEFAULT (N'OUT LOCKER') NULL,
    [REQUEST_TO_BRANCH_CODE]     NVARCHAR (50)   NULL,
    [REQUEST_TO_BRANCH_NAME]     NVARCHAR (250)  NULL,
    [REQUEST_FROM_DEPT_CODE]     NVARCHAR (50)   NULL,
    [REQUEST_FROM_DEPT_NAME]     NVARCHAR (250)  NULL,
    [REQUEST_TO_DEPT_CODE]       NVARCHAR (50)   NULL,
    [REQUEST_TO_DEPT_NAME]       NVARCHAR (250)  NULL,
    [REQUEST_TO_THIRDPARTY_TYPE] NVARCHAR (50)   NULL,
    [REQUEST_BY]                 NVARCHAR (250)  CONSTRAINT [DF_DOCUMENT_REQUEST_MUTATION_BY] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_STATUS]             NVARCHAR (50)   CONSTRAINT [DF_DOCUMENT_REQUEST_REQUEST_TO1] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_DATE]               DATETIME        NOT NULL,
    [REMARKS]                    NVARCHAR (4000) NOT NULL,
    [DOCUMENT_CODE]              NVARCHAR (50)   CONSTRAINT [DF_DOCUMENT_REQUEST_DOCUMENT_CODE] DEFAULT ('') NOT NULL,
    [AGREEMENT_NO]               NVARCHAR (50)   NULL,
    [COLLATERAL_NO]              NVARCHAR (50)   NULL,
    [ASSET_NO]                   NVARCHAR (50)   NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_DOCUMENT_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_LOCATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI FROM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TO_AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI FROM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TO_CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI FROM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TO_THIRDPARTY_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_STATUS';

