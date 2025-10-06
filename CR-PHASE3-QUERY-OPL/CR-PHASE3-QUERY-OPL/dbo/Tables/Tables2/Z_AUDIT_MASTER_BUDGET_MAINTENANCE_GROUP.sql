CREATE TABLE [dbo].[Z_AUDIT_MASTER_BUDGET_MAINTENANCE_GROUP] (
    [CODE]                    NVARCHAR (50)  NOT NULL,
    [BUDGET_MAINTENANCE_CODE] NVARCHAR (50)  NOT NULL,
    [GROUP_CODE]              NVARCHAR (50)  NOT NULL,
    [GROUP_DESCRIPTION]       NVARCHAR (250) NOT NULL,
    [PROBABILITY_PCT]         DECIMAL (9, 6) NOT NULL,
    [CRE_DATE]                DATETIME       NOT NULL,
    [CRE_BY]                  NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                DATETIME       NOT NULL,
    [MOD_BY]                  NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)  NOT NULL,
    [AuditDataState]          VARCHAR (10)   NULL,
    [AuditDMLAction]          VARCHAR (10)   NULL,
    [AuditUser]               [sysname]      NULL,
    [AuditDateTime]           DATETIME       NULL,
    [UpdateColumns]           VARCHAR (MAX)  NULL
);

