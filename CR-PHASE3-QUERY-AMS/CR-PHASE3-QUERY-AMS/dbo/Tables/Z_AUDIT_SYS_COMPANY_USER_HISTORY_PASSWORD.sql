CREATE TABLE [dbo].[Z_AUDIT_SYS_COMPANY_USER_HISTORY_PASSWORD] (
    [RUNNING_NUMBER]   INT           NOT NULL,
    [USER_CODE]        NVARCHAR (50) NULL,
    [PASSWORD_TYPE]    NVARCHAR (10) NOT NULL,
    [DATE_CHANGE_PASS] DATETIME      NOT NULL,
    [OLDPASS]          NVARCHAR (20) NOT NULL,
    [NEWPASS]          NVARCHAR (20) NOT NULL,
    [CRE_DATE]         DATETIME      NOT NULL,
    [CRE_BY]           NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15) NOT NULL,
    [MOD_DATE]         DATETIME      NOT NULL,
    [MOD_BY]           NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15) NOT NULL,
    [AuditDataState]   VARCHAR (10)  NULL,
    [AuditDMLAction]   VARCHAR (10)  NULL,
    [AuditUser]        [sysname]     NULL,
    [AuditDateTime]    DATETIME      NULL,
    [UpdateColumns]    VARCHAR (MAX) NULL
);

