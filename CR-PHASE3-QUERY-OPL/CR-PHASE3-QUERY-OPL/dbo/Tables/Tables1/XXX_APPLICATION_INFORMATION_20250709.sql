CREATE TABLE [dbo].[XXX_APPLICATION_INFORMATION_20250709] (
    [APPLICATION_NO]                    NVARCHAR (50)   NOT NULL,
    [WORKFLOW_STEP]                     INT             NULL,
    [APPLICATION_FLOW_CODE]             NVARCHAR (50)   NULL,
    [SCREEN_FLOW_CODE]                  NVARCHAR (50)   NULL,
    [CLIENT_FLOW_CODE]                  NVARCHAR (50)   NULL,
    [IS_REFUNDED]                       NVARCHAR (1)    NOT NULL,
    [INTEREST_FOR_FIRST_DUEDATE_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [GROUP_LIMIT_AMOUNT]                DECIMAL (18, 2) NOT NULL,
    [OS_EXPOSURE_AMOUNT]                DECIMAL (18, 2) NOT NULL,
    [REFF_LOAN_NO]                      NVARCHAR (50)   NULL,
    [CRE_DATE]                          DATETIME        NOT NULL,
    [CRE_BY]                            NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                    NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                          DATETIME        NOT NULL,
    [MOD_BY]                            NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                    NVARCHAR (15)   NOT NULL,
    [APPROVAL_CODE]                     NVARCHAR (50)   NULL
);

