CREATE TABLE [dbo].[Z_AUDIT_SYS_JOB_TASKLIST] (
    [CODE]           NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TYPE]           NVARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DESCRIPTION]    NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SP_NAME]        NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ORDER_NO]       INT             NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ROW_TO_PROCESS] INT             NOT NULL,
    [EOD_STATUS]     NVARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EOD_REMARK]     NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LAST_ID]        BIGINT          NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [AuditDataState] VARCHAR (10)    NULL,
    [AuditDMLAction] VARCHAR (10)    NULL,
    [AuditUser]      [sysname]       NULL,
    [AuditDateTime]  DATETIME        NULL,
    [UpdateColumns]  VARCHAR (MAX)   NULL
);

