CREATE TABLE [dbo].[FIN_INTERFACE_AGREEMENT_UPDATE] (
    [ID]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]              NVARCHAR (50)   NOT NULL,
    [AGREEMENT_STATUS]          NVARCHAR (10)   NOT NULL,
    [AGREEMENT_SUB_STATUS]      NVARCHAR (20)   NOT NULL,
    [TERMINATION_DATE]          DATETIME        NULL,
    [TERMINATION_STATUS]        NVARCHAR (20)   NULL,
    [CLIENT_NO]                 NVARCHAR (50)   NULL,
    [CLIENT_NAME]               NVARCHAR (250)  NULL,
    [NEXT_DUE_DATE]             DATETIME        NULL,
    [PAYMENT_WITH_CODE]         NVARCHAR (50)   NULL,
    [PAYMENT_WITH_NAME]         NVARCHAR (250)  CONSTRAINT [DF_FIN_INTERFACE_AGREEMENT_UPDATE_PAYMENT_WITH_NAME] DEFAULT ('') NULL,
    [LAST_PAID_PERIOD]          INT             NULL,
    [LAST_INSTALLMENT_DUE_DATE] DATETIME        NULL,
    [OVERDUE_PERIOD]            INT             CONSTRAINT [DF_FIN_INTERFACE_AGREEMENT_UPDATE_OVERDUE_PERIOD] DEFAULT ((0)) NOT NULL,
    [OVERDUE_DAYS]              INT             CONSTRAINT [DF_FIN_INTERFACE_AGREEMENT_UPDATE_OVERDUE_DAYS] DEFAULT ((0)) NOT NULL,
    [IS_WO]                     NVARCHAR (1)    CONSTRAINT [DF_FIN_INTERFACE_AGREEMENT_UPDATE_IS_WO] DEFAULT ((0)) NOT NULL,
    [JOB_STATUS]                NVARCHAR (10)   CONSTRAINT [DF_FIN_INTERFACE_AGREEMENT_UPDATE_JOB_STATUS] DEFAULT (N'HOLD') NOT NULL,
    [FAILED_REMARKS]            NVARCHAR (4000) NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_FIN_INTERFACE_AGREEMENT_UPDATE] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode metode pembayaran yang digunakan pada kontrak pembiayaan tersebut - TRANSFER, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara transfer - PDC, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cek atau pdc - CASH, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara uang cash di kasir cabang - PAYMENTPOINT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar pada payment point - AUTODEBIT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara autodebit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_AGREEMENT_UPDATE', @level2type = N'COLUMN', @level2name = N'PAYMENT_WITH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Metode pembayaran yang digunakan pada kontrak pembiayaan tersebut - TRANSFER, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara transfer - PDC, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cek atau pdc - CASH, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara uang cash di kasir cabang - PAYMENTPOINT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar pada payment point - AUTODEBIT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara autodebit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_AGREEMENT_UPDATE', @level2type = N'COLUMN', @level2name = N'PAYMENT_WITH_NAME';

