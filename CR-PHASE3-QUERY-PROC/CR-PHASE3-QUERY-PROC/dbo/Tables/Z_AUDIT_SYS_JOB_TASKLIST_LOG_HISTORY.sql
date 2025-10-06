CREATE TABLE [dbo].[Z_AUDIT_SYS_JOB_TASKLIST_LOG_HISTORY] (
    [ID]                BIGINT         NULL,
    [JOB_TASKLIST_CODE] NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [STATUS]            NVARCHAR (20)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [START_DATE]        DATETIME       NOT NULL,
    [END_DATE]          DATETIME       NOT NULL,
    [LOG_DESCRIPTION]   NVARCHAR (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [RUN_BY]            NVARCHAR (20)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FROM_ID]           BIGINT         NOT NULL,
    [TO_ID]             BIGINT         NOT NULL,
    [NUMBER_OF_ROWS]    INT            NOT NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [AuditDataState]    VARCHAR (10)   NULL,
    [AuditDMLAction]    VARCHAR (10)   NULL,
    [AuditUser]         [sysname]      NULL,
    [AuditDateTime]     DATETIME       NULL,
    [UpdateColumns]     VARCHAR (MAX)  NULL
);

