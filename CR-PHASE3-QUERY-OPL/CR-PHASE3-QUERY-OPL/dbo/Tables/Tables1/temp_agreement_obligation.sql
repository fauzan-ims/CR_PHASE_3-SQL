CREATE TABLE [dbo].[temp_agreement_obligation] (
    [CODE]               NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]       NVARCHAR (50)   NOT NULL,
    [ASSET_NO]           NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]         NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]     INT             NOT NULL,
    [OBLIGATION_DAY]     INT             NOT NULL,
    [OBLIGATION_DATE]    DATETIME        NOT NULL,
    [OBLIGATION_TYPE]    NVARCHAR (10)   NOT NULL,
    [OBLIGATION_NAME]    NVARCHAR (250)  NOT NULL,
    [OBLIGATION_REFF_NO] NVARCHAR (50)   NOT NULL,
    [OBLIGATION_AMOUNT]  DECIMAL (18, 2) NOT NULL,
    [REMARKS]            NVARCHAR (4000) NOT NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL
);

