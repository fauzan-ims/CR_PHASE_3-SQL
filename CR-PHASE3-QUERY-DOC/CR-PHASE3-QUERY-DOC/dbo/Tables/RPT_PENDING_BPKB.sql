CREATE TABLE [dbo].[RPT_PENDING_BPKB] (
    [USER_ID]             NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]      NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]        NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]        NVARCHAR (50)   NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NULL,
    [SUPPLIER_NAME]       NVARCHAR (250)  NULL,
    [OVERDUE_DAYS]        INT             NULL,
    [UNIT]                INT             NULL,
    [OUT_STANDING]        INT             NULL,
    [COVER_NOTE_NO]       NVARCHAR (50)   NULL,
    [COVER_NOTE_EXP_DATE] DATETIME        NULL,
    [ALASAN_PENDING]      NVARCHAR (4000) NULL,
    [FILTER_SUPPLIER]     NVARCHAR (250)  NULL,
    [IS_CONDITION]        NVARCHAR (1)    NULL
);

