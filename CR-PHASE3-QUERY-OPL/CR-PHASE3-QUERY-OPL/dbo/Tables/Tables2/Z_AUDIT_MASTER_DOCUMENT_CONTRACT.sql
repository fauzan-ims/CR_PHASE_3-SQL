CREATE TABLE [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [DOCUMENT_TYPE]  NVARCHAR (4)   NOT NULL,
    [TEMPLATE_NAME]  NVARCHAR (250) NULL,
    [RPT_NAME]       NVARCHAR (250) NULL,
    [SP_NAME]        NVARCHAR (250) NOT NULL,
    [TABLE_NAME]     NVARCHAR (250) NOT NULL,
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

