CREATE TABLE [dbo].[Z_AUDIT_MASTER_TRANSACTION] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [COMPANY_CODE]     NVARCHAR (50)  NOT NULL,
    [TRANSACTION_NAME] NVARCHAR (250) NOT NULL,
    [MODULE_CODE]      NVARCHAR (50)  NOT NULL,
    [MODULE_NAME]      NVARCHAR (250) NOT NULL,
    [API_URL]          NVARCHAR (250) NULL,
    [SP_NAME]          NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]        NVARCHAR (1)   NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [AuditDataState]   VARCHAR (10)   NULL,
    [AuditDMLAction]   VARCHAR (10)   NULL,
    [AuditUser]        [sysname]      NULL,
    [AuditDateTime]    DATETIME       NULL,
    [UpdateColumns]    VARCHAR (MAX)  NULL
);

