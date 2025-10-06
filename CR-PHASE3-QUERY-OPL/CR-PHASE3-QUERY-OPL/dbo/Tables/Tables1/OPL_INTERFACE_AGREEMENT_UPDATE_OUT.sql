CREATE TABLE [dbo].[OPL_INTERFACE_AGREEMENT_UPDATE_OUT] (
    [ID]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]                   NVARCHAR (50)   NOT NULL,
    [AGREEMENT_STATUS]               NVARCHAR (10)   NOT NULL,
    [AGREEMENT_SUB_STATUS]           NVARCHAR (20)   NOT NULL,
    [TERMINATION_DATE]               DATETIME        NULL,
    [TERMINATION_STATUS]             NVARCHAR (20)   NULL,
    [CLIENT_NO]                      NVARCHAR (50)   NOT NULL,
    [CLIENT_NAME]                    NVARCHAR (250)  NOT NULL,
    [NEXT_DUE_DATE]                  DATETIME        NULL,
    [LAST_PAID_PERIOD]               INT             NOT NULL,
    [LAST_INSTALLMENT_DUE_DATE]      DATETIME        NULL,
    [OVERDUE_PERIOD]                 INT             NOT NULL,
    [OVERDUE_DAYS]                   INT             NOT NULL,
    [OUTSTANDING_DEPOSIT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_UPDATE_OUT_OUTSTANDING_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TENOR]                          INT             CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_UPDATE_OUT_TENOR] DEFAULT ((0)) NOT NULL,
    [OVERDUE_PENALTY_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_UPDATE_OUT_OVERDUE_PENALTY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [OVERDUE_INSTALLMENT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_UPDATE_OUT_OVERDUE_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_INSTALLMENT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_UPDATE_OUT_OUTSTANDING_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [IS_WO]                          NVARCHAR (1)    NOT NULL,
    [INSTALLMENT_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_UPDATE_OUT_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [OS_PRINCIPAL_AMOUNT]            DECIMAL (18, 2) NULL,
    [OS_INTEREST_AMOUNT]             DECIMAL (18, 2) NULL,
    [OS_TENOR]                       INT             NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_AGREEMENT_UPDATE_OUT] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa deposit pada data kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_UPDATE_OUT', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah angsuran pada data kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_UPDATE_OUT', @level2type = N'COLUMN', @level2name = N'TENOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai denda keterlambatan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_UPDATE_OUT', @level2type = N'COLUMN', @level2name = N'OVERDUE_PENALTY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai keterlambatan angsuran pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_UPDATE_OUT', @level2type = N'COLUMN', @level2name = N'OVERDUE_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa angsuran pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_UPDATE_OUT', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai keterlambatan angsuran pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_UPDATE_OUT', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_AMOUNT';

