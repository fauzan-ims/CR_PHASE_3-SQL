CREATE TABLE [dbo].[Z_AUDIT_MASTER_BARCODE_REGISTER_DETAIL] (
    [ID]                    BIGINT        NULL,
    [BARCODE_REGISTER_CODE] NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [BARCODE_NO]            NVARCHAR (50) NOT NULL,
    [ASSET_CODE]            NVARCHAR (50) NOT NULL,
    [STATUS]                NVARCHAR (20) NOT NULL,
    [CRE_DATE]              DATETIME      NOT NULL,
    [CRE_BY]                NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    [MOD_DATE]              DATETIME      NOT NULL,
    [MOD_BY]                NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    [AuditDataState]        VARCHAR (10)  NULL,
    [AuditDMLAction]        VARCHAR (10)  NULL,
    [AuditUser]             [sysname]     NULL,
    [AuditDateTime]         DATETIME      NULL,
    [UpdateColumns]         VARCHAR (MAX) NULL
);

