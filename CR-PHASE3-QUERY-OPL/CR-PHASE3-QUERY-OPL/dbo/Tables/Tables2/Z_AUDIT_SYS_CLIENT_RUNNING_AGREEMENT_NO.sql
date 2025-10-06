CREATE TABLE [dbo].[Z_AUDIT_SYS_CLIENT_RUNNING_AGREEMENT_NO] (
    [CLIENT_CODE]         NVARCHAR (50) NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50) NOT NULL,
    [RUNNING_CLIENT_CODE] NVARCHAR (10) NOT NULL,
    [RUNNING_CLIENT_NO]   NVARCHAR (10) NOT NULL,
    [CRE_DATE]            DATETIME      NOT NULL,
    [CRE_BY]              NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    [MOD_DATE]            DATETIME      NOT NULL,
    [MOD_BY]              NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    [AuditDataState]      VARCHAR (10)  NULL,
    [AuditDMLAction]      VARCHAR (10)  NULL,
    [AuditUser]           [sysname]     NULL,
    [AuditDateTime]       DATETIME      NULL,
    [UpdateColumns]       VARCHAR (MAX) NULL
);

