CREATE TABLE [dbo].[Z_AUDIT_SYS_ROLE_GROUP_DETAIL] (
    [ID]              BIGINT         NULL,
    [ROLE_GROUP_CODE] NVARCHAR (50)  NOT NULL,
    [ROLE_CODE]       NVARCHAR (50)  NOT NULL,
    [ROLE_NAME]       NVARCHAR (250) NOT NULL,
    [MENU_CODE]       NVARCHAR (50)  NOT NULL,
    [MENU_NAME]       NVARCHAR (250) NOT NULL,
    [SUBMENU_CODE]    NVARCHAR (50)  NOT NULL,
    [SUBMENU_NAME]    NVARCHAR (250) NOT NULL,
    [CRE_DATE]        DATETIME       NOT NULL,
    [CRE_BY]          NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    [MOD_DATE]        DATETIME       NOT NULL,
    [MOD_BY]          NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    [AuditDataState]  VARCHAR (10)   NULL,
    [AuditDMLAction]  VARCHAR (10)   NULL,
    [AuditUser]       [sysname]      NULL,
    [AuditDateTime]   DATETIME       NULL,
    [UpdateColumns]   VARCHAR (MAX)  NULL
);

