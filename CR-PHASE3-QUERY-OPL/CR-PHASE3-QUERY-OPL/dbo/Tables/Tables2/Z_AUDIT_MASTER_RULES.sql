CREATE TABLE [dbo].[Z_AUDIT_MASTER_RULES] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]      NVARCHAR (250) NOT NULL,
    [FUNCTION_NAME]    NVARCHAR (250) NOT NULL,
    [TYPE]             NVARCHAR (15)  NULL,
    [IS_FN_OVERRIDE]   NVARCHAR (1)   NOT NULL,
    [FN_OVERRIDE_NAME] NVARCHAR (250) NULL,
    [IS_ACTIVE]        NVARCHAR (1)   NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [AuditDataState]   VARCHAR (10)   NULL,
    [AuditDMLAction]   VARCHAR (10)   NULL,
    [AuditUser]        [sysname]      NULL,
    [AuditDateTime]    DATETIME       NULL,
    [UpdateColumns]    VARCHAR (MAX)  NULL
);

