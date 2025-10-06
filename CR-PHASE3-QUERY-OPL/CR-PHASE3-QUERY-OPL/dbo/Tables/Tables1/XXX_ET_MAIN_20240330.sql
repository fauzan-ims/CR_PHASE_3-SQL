CREATE TABLE [dbo].[XXX_ET_MAIN_20240330] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NOT NULL,
    [ET_STATUS]             NVARCHAR (10)   NOT NULL,
    [ET_DATE]               DATETIME        NOT NULL,
    [ET_EXP_DATE]           DATETIME        NOT NULL,
    [ET_AMOUNT]             DECIMAL (18, 2) NOT NULL,
    [ET_REMARKS]            NVARCHAR (4000) NOT NULL,
    [RECEIVED_REQUEST_CODE] NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_NO]   NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_DATE] DATETIME        NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL
);

