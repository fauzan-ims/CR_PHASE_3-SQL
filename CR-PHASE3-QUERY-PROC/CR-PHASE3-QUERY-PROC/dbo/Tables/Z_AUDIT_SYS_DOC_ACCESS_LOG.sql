CREATE TABLE [dbo].[Z_AUDIT_SYS_DOC_ACCESS_LOG] (
    [ID]               BIGINT         NULL,
    [MODULE_NAME]      NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TRANSACTION_NAME] NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TRANSACTION_NO]   NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ACCESS_DATE]      DATETIME       NOT NULL,
    [ACESS_TYPE]       NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FILE_NAME]        NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PRINT_BY_CODE]    NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PRINT_BY_NAME]    NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PRINT_BY_IP]      NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [AuditDataState]   VARCHAR (10)   NULL,
    [AuditDMLAction]   VARCHAR (10)   NULL,
    [AuditUser]        [sysname]      NULL,
    [AuditDateTime]    DATETIME       NULL,
    [UpdateColumns]    VARCHAR (MAX)  NULL
);

