CREATE TABLE [dbo].[Z_AUDIT_MASTER_ROUNDING_DETAIL] (
    [ID]              BIGINT          NULL,
    [ROUNDING_CODE]   NVARCHAR (50)   NOT NULL,
    [FACILITY_CODE]   NVARCHAR (50)   NOT NULL,
    [ROUNDING_TYPE]   NVARCHAR (10)   NOT NULL,
    [ROUNDING_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [AuditDataState]  VARCHAR (10)    NULL,
    [AuditDMLAction]  VARCHAR (10)    NULL,
    [AuditUser]       [sysname]       NULL,
    [AuditDateTime]   DATETIME        NULL,
    [UpdateColumns]   VARCHAR (MAX)   NULL
);

