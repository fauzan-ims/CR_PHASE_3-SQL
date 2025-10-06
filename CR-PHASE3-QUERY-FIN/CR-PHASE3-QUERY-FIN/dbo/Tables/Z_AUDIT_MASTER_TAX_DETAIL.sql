CREATE TABLE [dbo].[Z_AUDIT_MASTER_TAX_DETAIL] (
    [ID]                     BIGINT          NULL,
    [TAX_CODE]               NVARCHAR (50)   NOT NULL,
    [EFFECTIVE_DATE]         DATETIME        NOT NULL,
    [FROM_VALUE_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [TO_VALUE_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [WITH_TAX_NUMBER_PCT]    DECIMAL (9, 6)  NOT NULL,
    [WITHOUT_TAX_NUMBER_PCT] DECIMAL (9, 6)  NOT NULL,
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

