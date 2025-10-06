CREATE TABLE [dbo].[Z_AUDIT_SYS_COMPANY_USER_MAIN_GROUP_SEC] (
    [ROLE_GROUP_CODE] NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [USER_CODE]       NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]        DATETIME      NOT NULL,
    [CRE_BY]          NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15) NOT NULL,
    [MOD_DATE]        DATETIME      NOT NULL,
    [MOD_BY]          NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15) NOT NULL,
    [AuditDataState]  VARCHAR (10)  NULL,
    [AuditDMLAction]  VARCHAR (10)  NULL,
    [AuditUser]       [sysname]     NULL,
    [AuditDateTime]   DATETIME      NULL,
    [UpdateColumns]   VARCHAR (MAX) NULL
);

