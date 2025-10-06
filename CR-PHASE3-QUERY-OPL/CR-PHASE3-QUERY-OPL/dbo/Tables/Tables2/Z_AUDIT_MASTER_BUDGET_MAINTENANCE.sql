CREATE TABLE [dbo].[Z_AUDIT_MASTER_BUDGET_MAINTENANCE] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [UNIT_CODE]        NVARCHAR (50)  NOT NULL,
    [UNIT_DESCRIPTION] NVARCHAR (250) NOT NULL,
    [YEAR]             INT            NOT NULL,
    [INFLATION]        DECIMAL (9, 6) NOT NULL,
    [LOCATION]         NVARCHAR (10)  NOT NULL,
    [EFF_DATE]         DATETIME       NOT NULL,
    [EXP_DATE]         DATETIME       NULL,
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

