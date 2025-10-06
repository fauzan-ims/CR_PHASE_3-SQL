CREATE TABLE [dbo].[Z_AUDIT_SYS_TODO] (
    [CODE]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TODO_NAME]      NVARCHAR (250) NOT NULL,
    [LINK_ADDRESS]   NVARCHAR (250) NOT NULL,
    [QUERY]          NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)   NOT NULL,
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

