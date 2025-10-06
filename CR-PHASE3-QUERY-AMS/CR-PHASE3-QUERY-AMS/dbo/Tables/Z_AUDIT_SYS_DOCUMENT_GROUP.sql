CREATE TABLE [dbo].[Z_AUDIT_SYS_DOCUMENT_GROUP] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [COMPANY_CODE]   NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [TYPE_CODE]      NVARCHAR (50)  NOT NULL,
    [DIM_COUNT]      NVARCHAR (2)   NULL,
    [IS_ACTIVE]      NVARCHAR (50)  NOT NULL,
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

