CREATE TABLE [dbo].[FIN_INTERFACE_APPROVAL_REQUEST] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [REQUEST_STATUS]         NVARCHAR (50)   NOT NULL,
    [REQUEST_DATE]           DATETIME        NOT NULL,
    [REQUEST_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [REQUEST_REMARKS]        NVARCHAR (4000) NOT NULL,
    [REFF_MODULE_CODE]       NVARCHAR (10)   NOT NULL,
    [REFF_NO]                NVARCHAR (50)   NOT NULL,
    [REFF_NAME]              NVARCHAR (250)  NOT NULL,
    [PATHS]                  NVARCHAR (250)  NULL,
    [APPROVAL_CATEGORY_CODE] NVARCHAR (50)   NULL,
    [APPROVAL_STATUS]        NVARCHAR (10)   NULL,
    [SETTLE_DATE]            DATETIME        NULL,
    [JOB_STATUS]             NVARCHAR (10)   CONSTRAINT [DF_FIN_INTERFACE_APPROVAL_REQUEST_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARKS]         NVARCHAR (4000) NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [REQUESTOR_CODE]         NVARCHAR (50)   NULL,
    [REQUESTOR_NAME]         NVARCHAR (50)   NULL,
    CONSTRAINT [PK_FIN_INTERFACE_APPROVAL_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'APPROVE, REJECT, RETURN, ESCALATION, NO RESULT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_APPROVAL_REQUEST', @level2type = N'COLUMN', @level2name = N'APPROVAL_STATUS';

