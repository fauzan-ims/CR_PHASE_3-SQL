CREATE TABLE [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE] (
    [CODE]                     NVARCHAR (50) NOT NULL,
    [INSURANCE_CODE]           NVARCHAR (50) NOT NULL,
    [COLLATERAL_TYPE_CODE]     NVARCHAR (50) NOT NULL,
    [COLLATERAL_CATEGORY_CODE] NVARCHAR (50) NOT NULL,
    [COVERAGE_CODE]            NVARCHAR (50) NOT NULL,
    [DAY_IN_YEAR]              NVARCHAR (10) NOT NULL,
    [REGION_CODE]              NVARCHAR (50) NULL,
    [OCCUPATION_CODE]          NVARCHAR (50) NULL,
    [IS_ACTIVE]                NVARCHAR (1)  NOT NULL,
    [CRE_DATE]                 DATETIME      NOT NULL,
    [CRE_BY]                   NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15) NOT NULL,
    [MOD_DATE]                 DATETIME      NOT NULL,
    [MOD_BY]                   NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15) NOT NULL,
    [AuditDataState]           VARCHAR (10)  NULL,
    [AuditDMLAction]           VARCHAR (10)  NULL,
    [AuditUser]                [sysname]     NULL,
    [AuditDateTime]            DATETIME      NULL,
    [UpdateColumns]            VARCHAR (MAX) NULL
);

