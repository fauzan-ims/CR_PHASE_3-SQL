CREATE TABLE [dbo].[Z_AUDIT_SYS_DOCUMENT_UPLOAD] (
    [ID]             BIGINT          NULL,
    [REFF_NO]        NVARCHAR (50)   NOT NULL,
    [REFF_NAME]      NVARCHAR (250)  NOT NULL,
    [REFF_TRX_CODE]  NVARCHAR (50)   NOT NULL,
    [FILE_NAME]      NVARCHAR (250)  NOT NULL,
    [DOC_FILE]       VARBINARY (MAX) NOT NULL,
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

