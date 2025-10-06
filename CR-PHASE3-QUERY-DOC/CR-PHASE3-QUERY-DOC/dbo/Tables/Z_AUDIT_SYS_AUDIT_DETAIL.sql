CREATE TABLE [dbo].[Z_AUDIT_SYS_AUDIT_DETAIL] (
    [ID]             BIGINT          NULL,
    [AUDIT_CODE]     NVARCHAR (50)   NOT NULL,
    [DATE]           DATETIME        NOT NULL,
    [PROGRESS]       NVARCHAR (250)  NOT NULL,
    [REMARK]         NVARCHAR (4000) NOT NULL,
    [FILE_NAME]      NVARCHAR (250)  NULL,
    [PATHS]          NVARCHAR (250)  NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [AuditDataState] VARCHAR (10)    NULL,
    [AuditDMLAction] VARCHAR (10)    NULL,
    [AuditUser]      [sysname]       NULL,
    [AuditDateTime]  DATETIME        NULL,
    [UpdateColumns]  VARCHAR (MAX)   NULL
);

