CREATE TABLE [dbo].[Z_AUDIT_SYS_CALENDER_EMPLOYEE] (
    [ID]             BIGINT        NULL,
    [TITLE]          NVARCHAR (50) NOT NULL,
    [START]          NVARCHAR (50) NOT NULL,
    [ENDDAY]         NVARCHAR (50) NOT NULL,
    [CLASSNAME]      NVARCHAR (50) NOT NULL,
    [EMPLOYEE_CODE]  NVARCHAR (50) NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [AuditDataState] VARCHAR (10)  NULL,
    [AuditDMLAction] VARCHAR (10)  NULL,
    [AuditUser]      [sysname]     NULL,
    [AuditDateTime]  DATETIME      NULL,
    [UpdateColumns]  VARCHAR (MAX) NULL
);

