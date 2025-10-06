CREATE TABLE [dbo].[Z_AUDIT_MASTER_AUCTION_BANK] (
    [ID]                BIGINT         NULL,
    [AUCTION_CODE]      NVARCHAR (50)  NOT NULL,
    [CURRENCY_CODE]     NVARCHAR (3)   NOT NULL,
    [BANK_CODE]         NVARCHAR (50)  NOT NULL,
    [BANK_NAME]         NVARCHAR (250) NOT NULL,
    [BANK_BRANCH]       NVARCHAR (250) NOT NULL,
    [BANK_ACCOUNT_NO]   NVARCHAR (50)  NOT NULL,
    [BANK_ACCOUNT_NAME] NVARCHAR (250) NOT NULL,
    [IS_DEFAULT]        NVARCHAR (1)   NOT NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [AuditDataState]    VARCHAR (10)   NULL,
    [AuditDMLAction]    VARCHAR (10)   NULL,
    [AuditUser]         [sysname]      NULL,
    [AuditDateTime]     DATETIME       NULL,
    [UpdateColumns]     VARCHAR (MAX)  NULL
);

