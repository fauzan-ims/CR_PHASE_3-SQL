CREATE TABLE [dbo].[Z_AUDIT_MASTER_COLLECTION_BUCKET] (
    [CODE]            NVARCHAR (50)  NOT NULL,
    [BUCKET_NAME]     NVARCHAR (100) NOT NULL,
    [OVERDUE_MIN_DAY] INT            NOT NULL,
    [OVERDUE_MAX_DAY] INT            NOT NULL,
    [FACILITY_CODE]   NVARCHAR (50)  NOT NULL,
    [FACILITY_NAME]   NVARCHAR (250) NOT NULL,
    [BUCKET_TYPE]     NVARCHAR (10)  NOT NULL,
    [IS_LIFE_BUCKET]  NVARCHAR (1)   NOT NULL,
    [IS_REMEDIAL]     NVARCHAR (1)   NOT NULL,
    [IS_ACTIVE]       NVARCHAR (1)   NOT NULL,
    [CRE_DATE]        DATETIME       NOT NULL,
    [CRE_BY]          NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    [MOD_DATE]        DATETIME       NOT NULL,
    [MOD_BY]          NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    [AuditDataState]  VARCHAR (10)   NULL,
    [AuditDMLAction]  VARCHAR (10)   NULL,
    [AuditUser]       [sysname]      NULL,
    [AuditDateTime]   DATETIME       NULL,
    [UpdateColumns]   VARCHAR (MAX)  NULL
);

