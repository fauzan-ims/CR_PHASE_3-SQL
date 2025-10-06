CREATE TABLE [dbo].[XXX_DUE_DATE_CHANGE_AMORTIZATION_HISTORY_20241206] (
    [DUE_DATE_CHANGE_CODE] NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]       INT             NOT NULL,
    [ASSET_NO]             NVARCHAR (50)   NOT NULL,
    [DUE_DATE]             DATETIME        NOT NULL,
    [BILLING_DATE]         DATETIME        NOT NULL,
    [BILLING_AMOUNT]       DECIMAL (18, 2) NOT NULL,
    [DESCRIPTION]          NVARCHAR (4000) NOT NULL,
    [OLD_OR_NEW]           NVARCHAR (3)    NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

