CREATE TABLE [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_DETAIL] (
    [ID]                     BIGINT          NULL,
    [VEHICLE_PRICELIST_CODE] NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [CURRENCY_CODE]          NVARCHAR (3)    NOT NULL,
    [EFFECTIVE_DATE]         DATETIME        NOT NULL,
    [ASSET_VALUE]            DECIMAL (18, 2) NOT NULL,
    [DP_PCT]                 DECIMAL (9, 6)  NOT NULL,
    [DP_AMOUNT]              DECIMAL (18, 2) NOT NULL,
    [FINANCING_AMOUNT]       DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [AuditDataState]         VARCHAR (10)    NULL,
    [AuditDMLAction]         VARCHAR (10)    NULL,
    [AuditUser]              [sysname]       NULL,
    [AuditDateTime]          DATETIME        NULL,
    [UpdateColumns]          VARCHAR (MAX)   NULL
);

