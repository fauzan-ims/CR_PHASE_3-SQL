CREATE TABLE [dbo].[Z_AUDIT_MASTER_COLLECTOR] (
    [CODE]                      NVARCHAR (50)  NOT NULL,
    [COLLECTOR_NAME]            NVARCHAR (250) NOT NULL,
    [SUPERVISOR_COLLECTOR_CODE] NVARCHAR (50)  NULL,
    [COLLECTOR_EMP_CODE]        NVARCHAR (50)  NOT NULL,
    [COLLECTOR_EMP_NAME]        NVARCHAR (250) NOT NULL,
    [MAX_LOAD_AGREEMENT]        INT            NOT NULL,
    [MAX_LOAD_DAILY_AGREEMENT]  INT            NOT NULL,
    [IS_ACTIVE]                 NVARCHAR (1)   NOT NULL,
    [CRE_DATE]                  DATETIME       NOT NULL,
    [CRE_BY]                    NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                  DATETIME       NOT NULL,
    [MOD_BY]                    NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)  NOT NULL,
    [AuditDataState]            VARCHAR (10)   NULL,
    [AuditDMLAction]            VARCHAR (10)   NULL,
    [AuditUser]                 [sysname]      NULL,
    [AuditDateTime]             DATETIME       NULL,
    [UpdateColumns]             VARCHAR (MAX)  NULL
);

