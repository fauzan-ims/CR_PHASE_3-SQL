CREATE TABLE [dbo].[RPT_BPKB_BORROW_REPORT] (
    [USER_ID]            NVARCHAR (50)  NOT NULL,
    [REPORT_COMPANY]     NVARCHAR (250) NOT NULL,
    [REPORT_TITLE]       NVARCHAR (250) NOT NULL,
    [REPORT_IMAGE]       NVARCHAR (250) NOT NULL,
    [FILTER_BRANCH_NAME] NVARCHAR (250) NULL,
    [BRANCH_CODE]        NVARCHAR (50)  NULL,
    [BRANCH_NAME]        NVARCHAR (250) NULL,
    [AS_OF_DATE]         DATETIME       NULL,
    [AGREEMENT_NO]       NVARCHAR (50)  NULL,
    [CLIENT_NAME]        NVARCHAR (250) NULL,
    [MERK]               NVARCHAR (250) NULL,
    [MODEL]              NVARCHAR (250) NULL,
    [TYPE]               NVARCHAR (250) NULL,
    [CHASSIS_NO]         NVARCHAR (50)  NULL,
    [ENGINE_NO]          NVARCHAR (50)  NULL,
    [BPKB_NO]            NVARCHAR (50)  NULL,
    [YEAR]               INT            NULL,
    [VENDOR]             NVARCHAR (250) NULL,
    [BORROWED_DATE]      DATETIME       NULL,
    [RETURNED_DATE]      DATETIME       NULL,
    [IS_CONDITION]       NVARCHAR (1)   NULL
);

