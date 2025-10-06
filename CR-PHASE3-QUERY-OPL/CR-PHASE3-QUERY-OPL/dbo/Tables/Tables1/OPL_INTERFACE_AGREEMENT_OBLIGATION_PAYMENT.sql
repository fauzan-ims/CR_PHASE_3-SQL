CREATE TABLE [dbo].[OPL_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]        NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]      INT             NULL,
    [OBLIGATION_TYPE]     NVARCHAR (10)   NOT NULL,
    [PAYMENT_DATE]        DATETIME        NOT NULL,
    [VALUE_DATE]          DATETIME        NOT NULL,
    [PAYMENT_SOURCE_TYPE] NVARCHAR (50)   NULL,
    [PAYMENT_SOURCE_NO]   NVARCHAR (50)   NOT NULL,
    [PAYMENT_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [PAYMENT_REMARKS]     NVARCHAR (4000) NOT NULL,
    [IS_WAIVE]            NVARCHAR (1)    NOT NULL,
    [JOB_STATUS]          NVARCHAR (20)   NULL,
    [FAILED_REMARK]       NVARCHAR (4000) NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';

