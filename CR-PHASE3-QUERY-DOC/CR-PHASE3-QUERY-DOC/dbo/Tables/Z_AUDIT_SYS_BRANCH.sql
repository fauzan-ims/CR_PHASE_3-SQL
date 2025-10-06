CREATE TABLE [dbo].[Z_AUDIT_SYS_BRANCH] (
    [BRANCH_CODE]         NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250) NOT NULL,
    [IS_CUSTODY_BRANCH]   NVARCHAR (1)   NOT NULL,
    [CUSTODY_BRANCH_CODE] NVARCHAR (50)  NOT NULL,
    [CUSTODY_BRANCH_NAME] NVARCHAR (250) NOT NULL,
    [CRE_DATE]            DATETIME       NOT NULL,
    [CRE_BY]              NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)  NOT NULL,
    [MOD_DATE]            DATETIME       NOT NULL,
    [MOD_BY]              NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)  NOT NULL,
    [AuditDataState]      VARCHAR (10)   NULL,
    [AuditDMLAction]      VARCHAR (10)   NULL,
    [AuditUser]           [sysname]      NULL,
    [AuditDateTime]       DATETIME       NULL,
    [UpdateColumns]       VARCHAR (MAX)  NULL
);

