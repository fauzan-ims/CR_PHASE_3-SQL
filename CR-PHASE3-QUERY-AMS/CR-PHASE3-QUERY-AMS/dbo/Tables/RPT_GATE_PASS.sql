CREATE TABLE [dbo].[RPT_GATE_PASS] (
    [GATE_PASS_CODE] NVARCHAR (50)   NULL,
    [USER_ID]        NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY] NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]   NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]   NVARCHAR (250)  NOT NULL,
    [BRANCH_NAME]    NVARCHAR (50)   NULL,
    [PLAT_NO]        NVARCHAR (50)   NULL,
    [TYPE]           NVARCHAR (50)   NULL,
    [COLOUR]         NVARCHAR (50)   NULL,
    [UNIT_STATUS]    NVARCHAR (50)   NULL,
    [KM_IN]          INT             NULL,
    [KM_OUT]         INT             NULL,
    [DATE_OUT]       DATETIME        NULL,
    [AGREEMENT_NO]   NVARCHAR (50)   NULL,
    [DELIVERY_TO]    NVARCHAR (4000) NULL,
    [KURIR]          NVARCHAR (50)   NULL,
    [REQUESTED_BY]   NVARCHAR (50)   NULL,
    [CRE_DATE]       DATETIME        NULL,
    [CRE_BY]         NVARCHAR (50)   NULL
);

