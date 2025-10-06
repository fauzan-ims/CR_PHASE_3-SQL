CREATE TABLE [dbo].[DOC_INTERFACE_INSURANCE_POLICY_MAIN] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [MODULE]                NVARCHAR (50)   NULL,
    [DOC_NO]                NVARCHAR (50)   NULL,
    [DOC_NAME]              NVARCHAR (250)  NULL,
    [DOC_TYPE]              NVARCHAR (250)  NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NULL,
    [COLLATERAL_NO]         NVARCHAR (50)   NULL,
    [PLAFOND_NO]            NVARCHAR (50)   NULL,
    [PLAFOND_COLLATERAL_NO] NVARCHAR (50)   NULL,
    [POLICY_EFF_DATE]       DATETIME        NULL,
    [POLICY_EXP_DATE]       DATETIME        NULL,
    [FILE_NAME]             NVARCHAR (250)  NULL,
    [PATHS]                 NVARCHAR (250)  NULL,
    [DOC_FILE]              VARBINARY (MAX) NULL,
    [JOB_STATUS]            NVARCHAR (20)   CONSTRAINT [DF_DOC_INTERFACE_INSURANCE_POLICY_MAIN_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARKS]        NVARCHAR (4000) NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INS_INTERFACE_SYS_GENERAL_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'MODULE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'DOC_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'DOC_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'DOC_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen atas data general dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'PATHS';

