CREATE TABLE [dbo].[Z_AUDIT_SYS_PREVIEW_LOG] (
    [ID]              BIGINT         NULL,
    [REPORT_CODE]     NVARCHAR (50)  NOT NULL,
    [REPORT_NAME]     NVARCHAR (250) NOT NULL,
    [PREVIEW_DATE]    DATETIME       NOT NULL,
    [PREVIEW_BY_CODE] NVARCHAR (50)  NOT NULL,
    [PREVIEW_BY_NAME] NVARCHAR (250) NOT NULL,
    [PREVIEW_BY_IP]   NVARCHAR (50)  NOT NULL,
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

