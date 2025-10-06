CREATE TABLE [dbo].[XXX_AGREEMENT_DEPOSIT_MAIN_07112023] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]          NVARCHAR (15)   NOT NULL,
    [DEPOSIT_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [DEPOSIT_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL
);

