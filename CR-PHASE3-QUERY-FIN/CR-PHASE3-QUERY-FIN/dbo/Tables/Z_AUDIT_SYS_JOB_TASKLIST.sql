CREATE TABLE [dbo].[Z_AUDIT_SYS_JOB_TASKLIST] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [TYPE]           NVARCHAR (20)   NOT NULL,
    [DESCRIPTION]    NVARCHAR (250)  NOT NULL,
    [SP_NAME]        NVARCHAR (250)  NOT NULL,
    [ORDER_NO]       INT             NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)    NOT NULL,
    [LAST_ID]        BIGINT          NOT NULL,
    [ROW_TO_PROCESS] INT             NOT NULL,
    [EOD_STATUS]     NVARCHAR (20)   NULL,
    [EOD_REMARK]     NVARCHAR (4000) NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [AuditDataState] VARCHAR (10)    NULL,
    [AuditDMLAction] VARCHAR (10)    NULL,
    [AuditUser]      [sysname]       NULL,
    [AuditDateTime]  DATETIME        NULL,
    [UpdateColumns]  VARCHAR (MAX)   NULL
);

