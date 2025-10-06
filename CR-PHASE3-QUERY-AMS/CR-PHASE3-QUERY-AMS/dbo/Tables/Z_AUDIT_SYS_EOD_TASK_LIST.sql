CREATE TABLE [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST] (
    [CODE]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NAME]           NVARCHAR (500) NOT NULL,
    [SP_NAME]        NVARCHAR (500) NOT NULL,
    [ORDER_NO]       INT            NOT NULL,
    [IS_DONE]        NVARCHAR (1)   NOT NULL,
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

