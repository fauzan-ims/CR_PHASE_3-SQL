CREATE TABLE [dbo].[DESKCOLL_MAIN] (
    [ID]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [DESK_DATE]                      DATETIME        NOT NULL,
    [DESK_STATUS]                    NVARCHAR (10)   CONSTRAINT [DF_DESKCOLL_MAIN_DESK_STATUS] DEFAULT (N'HOLD') NOT NULL,
    [DESK_COLLECTOR_CODE]            NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]                   NVARCHAR (50)   NULL,
    [LAST_PAID_INSTALLMENT_NO]       NVARCHAR (50)   CONSTRAINT [DF_DESKCOLL_MAIN_LAST_PAID_INSTALLMENT_NO] DEFAULT ('') NOT NULL,
    [INSTALLMENT_DUE_DATE]           DATETIME        NULL,
    [OVERDUE_PERIOD]                 INT             CONSTRAINT [DF_DESKCOLL_MAIN_OVERDUE_PERIOD] DEFAULT ((0)) NOT NULL,
    [OVERDUE_DAYS]                   INT             CONSTRAINT [DF_DESKCOLL_MAIN_OVERDUE_DAYS] DEFAULT ((0)) NOT NULL,
    [OVERDUE_PENALTY_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_DESKCOLL_MAIN_OVERDUE_PENALTY] DEFAULT ((0)) NOT NULL,
    [OVERDUE_INSTALLMENT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_DESKCOLL_MAIN_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_INSTALLMENT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_DESKCOLL_MAIN_OS_INSTALLMENT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_DEPOSIT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_DESKCOLL_MAIN_OS_DEPOSIT] DEFAULT ((0)) NOT NULL,
    [RESULT_CODE]                    NVARCHAR (50)   NULL,
    [RESULT_DETAIL_CODE]             NVARCHAR (50)   NULL,
    [RESULT_REMARKS]                 NVARCHAR (400)  NULL,
    [RESULT_PROMISE_DATE]            DATETIME        NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [CLIENT_NO]                      NVARCHAR (50)   NULL,
    [CLIENT_NAME]                    NVARCHAR (250)  NULL,
    [RESULT_PROMISE_AMOUNT]          DECIMAL (18, 2) NULL,
    [IS_NEED_NEXT_FU]                NVARCHAR (1)    NULL,
    [NEXT_FU_DATE]                   DATETIME        NULL,
    [POSTING_DATE]                   DATETIME        NULL,
    [POSTING_BY_CODE]                NVARCHAR (50)   NULL,
    [POSTING_BY_NAME]                NVARCHAR (250)  NULL,
    [DESKCOLL_STAFF_NAME]            NVARCHAR (250)  NULL,
    CONSTRAINT [PK_DESKCOLL_MAIN] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal task tersebut diberikan ke dekscoll', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'DESK_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deskcollection ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'DESK_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses dekcollection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran terakhir yang dibayar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_PAID_INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal jatuh tempo angsuran pada kontrak pembiayaan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_DUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah periode yang overdue', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari overdue pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_DAYS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai overdur penalti pada kontrak pembiayaan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_PENALTY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai keterlambatan angsuran pada kontrak pembiayaan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai outstanding angsuran pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai outstanding deposit pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode result dari hasil telepon deksollection', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'RESULT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode detail result dari hasil telepon deskcollection', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'RESULT_DETAIL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada hasil telepon deskcollection', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'RESULT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal janji client melakukan proses pembayaran pada proses deskcollection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESKCOLL_MAIN', @level2type = N'COLUMN', @level2name = N'RESULT_PROMISE_DATE';

