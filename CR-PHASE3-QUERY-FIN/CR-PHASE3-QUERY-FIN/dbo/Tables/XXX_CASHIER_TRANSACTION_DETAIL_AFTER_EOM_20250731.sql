CREATE TABLE [dbo].[XXX_CASHIER_TRANSACTION_DETAIL_AFTER_EOM_20250731] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [CASHIER_TRANSACTION_CODE] NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]         NVARCHAR (50)   NULL,
    [RECEIVED_REQUEST_CODE]    NVARCHAR (50)   NULL,
    [AGREEMENT_NO]             NVARCHAR (50)   NULL,
    [IS_PAID]                  NVARCHAR (1)    NOT NULL,
    [INNITIAL_AMOUNT]          DECIMAL (18, 2) NOT NULL,
    [ORIG_AMOUNT]              DECIMAL (18, 2) NOT NULL,
    [ORIG_CURRENCY_CODE]       NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]                DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]              DECIMAL (18, 2) NOT NULL,
    [INSTALLMENT_NO]           INT             NULL,
    [REMARKS]                  NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL
);

