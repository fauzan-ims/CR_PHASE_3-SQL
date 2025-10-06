CREATE TABLE [dbo].[EMAIL_NOTIF_TRANSACTION] (
    [ID]                   INT             IDENTITY (1, 1) NOT NULL,
    [MAIL_SENDER]          NVARCHAR (200)  NOT NULL,
    [MAIL_TO]              NVARCHAR (200)  NOT NULL,
    [MAIL_CC]              NVARCHAR (100)  NULL,
    [MAIL_BCC]             NVARCHAR (100)  NULL,
    [MAIL_SUBJECT]         NVARCHAR (200)  NOT NULL,
    [MAIL_BODY]            NVARCHAR (4000) NOT NULL,
    [MAIL_FILE_NAME]       NVARCHAR (100)  NULL,
    [MAIL_FILE_PATH]       NVARCHAR (250)  NULL,
    [GENERATE_FILE_STATUS] NVARCHAR (50)   NULL,
    [MAIL_STATUS]          NVARCHAR (50)   NOT NULL,
    [APPROVAL_NO]          NVARCHAR (50)   NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

