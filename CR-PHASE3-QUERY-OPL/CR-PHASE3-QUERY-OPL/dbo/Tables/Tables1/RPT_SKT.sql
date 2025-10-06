CREATE TABLE [dbo].[RPT_SKT] (
    [USER_ID]                     NVARCHAR (50)   NULL,
    [REPORT_COMPANY_NAME]         NVARCHAR (250)  NULL,
    [REPORT_IMAGE]                NVARCHAR (250)  NULL,
    [REPORT_TITLE]                NVARCHAR (250)  NULL,
    [LETTER_NO]                   NVARCHAR (50)   NULL,
    [LETTER_DATE]                 DATETIME        NULL,
    [EMPLOYEE_DELEGATOR_NAME]     NVARCHAR (250)  NULL,
    [EMPLOYEE_DELEGATOR_POSITION] NVARCHAR (50)   NULL,
    [EMPLOYEE_NAME]               NVARCHAR (250)  NULL,
    [EMPLOYEE_POSITION]           NVARCHAR (50)   NULL,
    [TOTAL_UNIT]                  INT             NULL,
    [ASSET_NAME]                  NVARCHAR (250)  NULL,
    [CLIENT_NAME]                 NVARCHAR (250)  NULL,
    [CLIENT_ADDRESS]              NVARCHAR (4000) NULL,
    [CONTRACT_NO]                 NVARCHAR (50)   NULL,
    [CRE_DATE]                    DATETIME        NULL,
    [CRE_BY]                      NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NULL,
    [MOD_DATE]                    DATETIME        NULL,
    [MOD_BY]                      NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NULL
);

