CREATE TABLE [dbo].[Z_AUDIT_SYS_REPORT] (
    [CODE]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NAME]           NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TABLE_NAME]     NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SP_NAME]        NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SCREEN_NAME]    NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [RPT_NAME]       NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MODULE_CODE]    NVARCHAR (50)  NOT NULL,
    [REPORT_TYPE]    NVARCHAR (15)  NULL,
    [IS_ACTIVE]      NVARCHAR (1)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [AuditDataState] VARCHAR (10)   NULL,
    [AuditDMLAction] VARCHAR (10)   NULL,
    [AuditUser]      [sysname]      NULL,
    [AuditDateTime]  DATETIME       NULL,
    [UpdateColumns]  VARCHAR (MAX)  NULL
);

