CREATE TABLE [dbo].[Z_AUDIT_MASTER_BUDGET_INSURANCE_RATE_EXTENTION] (
    [CODE]                 NVARCHAR (50)  NOT NULL,
    [COVERAGE_CODE]        NVARCHAR (50)  NOT NULL,
    [COVERAGE_DESCRIPTION] NVARCHAR (250) NOT NULL,
    [EXP_DATE]             DATETIME       NULL,
    [TLO]                  DECIMAL (9, 6) NOT NULL,
    [COMPRE]               DECIMAL (9, 6) NOT NULL,
    [REGION_CODE]          NVARCHAR (50)  NULL,
    [REGION_DESCRIPTION]   NVARCHAR (250) NULL,
    [IS_ACTIVE]            NVARCHAR (1)   NOT NULL,
    [CRE_DATE]             DATETIME       NOT NULL,
    [CRE_BY]               NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)  NOT NULL,
    [MOD_DATE]             DATETIME       NOT NULL,
    [MOD_BY]               NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)  NOT NULL,
    [AuditDataState]       VARCHAR (10)   NULL,
    [AuditDMLAction]       VARCHAR (10)   NULL,
    [AuditUser]            [sysname]      NULL,
    [AuditDateTime]        DATETIME       NULL,
    [UpdateColumns]        VARCHAR (MAX)  NULL
);

