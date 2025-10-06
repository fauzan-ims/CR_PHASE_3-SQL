CREATE TABLE [dbo].[Z_AUDIT_SYS_COMPANY_USER_LOGIN_LOG] (
    [ID]             BIGINT        NULL,
    [USER_CODE]      NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LOGIN_DATE]     DATETIME      NOT NULL,
    [FLAG_CODE]      NVARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SESSION_ID]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [AuditDataState] VARCHAR (10)  NULL,
    [AuditDMLAction] VARCHAR (10)  NULL,
    [AuditUser]      [sysname]     NULL,
    [AuditDateTime]  DATETIME      NULL,
    [UpdateColumns]  VARCHAR (MAX) NULL
);

