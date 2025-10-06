CREATE TABLE [dbo].[Z_AUDIT_SYS_TODO_EMPLOYEE] (
    [ID]             BIGINT         NULL,
    [EMPLOYEE_CODE]  NVARCHAR (50)  NOT NULL,
    [EMPLOYEE_NAME]  NVARCHAR (250) NOT NULL,
    [TODO_CODE]      NVARCHAR (50)  NOT NULL,
    [PRIORITY]       NVARCHAR (10)  NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [AuditDataState] VARCHAR (10)   NULL,
    [AuditDMLAction] VARCHAR (10)   NULL,
    [AuditUser]      [sysname]      NULL,
    [AuditDateTime]  DATETIME       NULL,
    [UpdateColumns]  VARCHAR (MAX)  NULL
);

