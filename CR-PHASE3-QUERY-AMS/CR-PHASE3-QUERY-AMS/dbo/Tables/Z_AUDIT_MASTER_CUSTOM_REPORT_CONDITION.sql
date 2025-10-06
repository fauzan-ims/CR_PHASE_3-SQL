CREATE TABLE [dbo].[Z_AUDIT_MASTER_CUSTOM_REPORT_CONDITION] (
    [ID]                  BIGINT          NULL,
    [CUSTOM_REPORT_CODE]  NVARCHAR (50)   NULL,
    [LOGICAL_OPERATOR]    NVARCHAR (20)   NULL,
    [COLUMN_NAME]         NVARCHAR (250)  NULL,
    [COMPARISON_OPERATOR] NVARCHAR (20)   NULL,
    [START_VALUE]         NVARCHAR (4000) NULL,
    [END_VALUE]           NVARCHAR (4000) NULL,
    [ORDER_KEY]           INT             NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [AuditDataState]      VARCHAR (10)    NULL,
    [AuditDMLAction]      VARCHAR (10)    NULL,
    [AuditUser]           [sysname]       NULL,
    [AuditDateTime]       DATETIME        NULL,
    [UpdateColumns]       VARCHAR (MAX)   NULL
);

