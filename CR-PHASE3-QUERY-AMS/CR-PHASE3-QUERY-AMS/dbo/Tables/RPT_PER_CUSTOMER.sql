CREATE TABLE [dbo].[RPT_PER_CUSTOMER] (
    [USER_ID]                      NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]               NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]                 NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]                 NVARCHAR (250)  NOT NULL,
    [BRANCH_CODE]                  NVARCHAR (50)   NULL,
    [BRANCH_NAME]                  NVARCHAR (50)   NULL,
    [CUSTOMER_NAME]                NVARCHAR (250)  NULL,
    [TOTAL_UNIT]                   INT             NULL,
    [TOTAL_BUDGET]                 DECIMAL (18, 2) NULL,
    [CURRENT_BUDGET]               DECIMAL (18, 2) NULL,
    [TOTAL_ACTUAL_COST]            DECIMAL (18, 2) NULL,
    [SISA_BUDGET]                  DECIMAL (18, 2) NULL,
    [ACTUAL_COS_OR_TOTAL_BUDGET]   DECIMAL (18, 6) NULL,
    [ACTUAL_COS_OR_CURRENT_BUDGET] DECIMAL (18, 6) NULL,
    [IS_CONDITION]                 NVARCHAR (1)    NULL
);

