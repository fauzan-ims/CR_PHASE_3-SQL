CREATE TABLE [dbo].[Z_AUDIT_SYS_GENERAL_DOCUMENT] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [DOCUMENT_NAME]  NVARCHAR (4000) NOT NULL,
    [IS_TEMP]        NVARCHAR (1)    NOT NULL,
    [IS_PHYSICAL]    NVARCHAR (1)    NOT NULL,
    [IS_ALLOW_OUT]   NVARCHAR (1)    NOT NULL,
    [IS_COLLATERAL]  NVARCHAR (1)    NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)    NOT NULL,
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

