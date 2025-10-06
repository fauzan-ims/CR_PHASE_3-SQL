CREATE TABLE [dbo].[FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL_TAX] (
    [ID]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [GL_LINK_TRANSACTION_CODE]      NVARCHAR (50)   NOT NULL,
    [GL_LINK_TRANSACTION_DETAIL_ID] BIGINT          NOT NULL,
    [PPH_TYPE]                      NVARCHAR (20)   NOT NULL,
    [VENDOR_CODE]                   NVARCHAR (50)   NOT NULL,
    [INCOME_TYPE]                   NVARCHAR (20)   NOT NULL,
    [INCOME_BRUTO_AMOUNT]           DECIMAL (18, 2) NOT NULL,
    [TAX_RATE_PCT]                  DECIMAL (5, 2)  NOT NULL,
    [PPH_AMOUNT]                    DECIMAL (18, 2) NOT NULL,
    [DESCRIPTION]                   NVARCHAR (4000) NOT NULL,
    [TAX_NUMBER]                    NVARCHAR (50)   NOT NULL,
    [SALE_TYPE]                     NVARCHAR (10)   NOT NULL,
    [CRE_DATE]                      DATETIME        NOT NULL,
    [CRE_BY]                        NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                      DATETIME        NOT NULL,
    [MOD_BY]                        NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                NVARCHAR (15)   NOT NULL
);

