CREATE TABLE [dbo].[TASK_MAIN] (
    [ID]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [TASK_DATE]                      DATETIME        NOT NULL,
    [DESK_COLLECTOR_CODE]            NVARCHAR (50)   NULL,
    [DESKCOLL_MAIN_ID]               BIGINT          NULL,
    [DESK_STATUS]                    NVARCHAR (10)   CONSTRAINT [DF_TASK_MAIN_DESK_STATUS] DEFAULT (N'NEW') NOT NULL,
    [FIELD_COLLECTOR_CODE]           NVARCHAR (50)   NULL,
    [FIELDCOLL_MAIN_CODE]            NVARCHAR (50)   NULL,
    [FIELD_STATUS]                   NVARCHAR (10)   CONSTRAINT [DF_TASK_MAIN_FIELD_STATUS] DEFAULT (N'NEW') NOT NULL,
    [AGREEMENT_NO]                   NVARCHAR (50)   NULL,
    [LAST_PAID_INSTALLMENT_NO]       NVARCHAR (50)   CONSTRAINT [DF_TASK_MAIN_LAST_PAID_INSTALLMENT_NO] DEFAULT ('') NOT NULL,
    [INSTALLMENT_DUE_DATE]           DATETIME        NULL,
    [OVERDUE_PERIOD]                 INT             CONSTRAINT [DF_TASK_MAIN_OVERDUE_PERIOD] DEFAULT ((0)) NOT NULL,
    [OVERDUE_DAYS]                   INT             CONSTRAINT [DF_TASK_MAIN_OVERDUE_DAYS] DEFAULT ((0)) NOT NULL,
    [OVERDUE_PENALTY_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_TASK_MAIN_OVERDUE_PENALTY] DEFAULT ((0)) NOT NULL,
    [OVERDUE_INSTALLMENT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_TASK_MAIN_OVERDUE_INSTALLMENT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_INSTALLMENT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_TASK_MAIN_OUTSTANDING_INSTALLMENT] DEFAULT ((0)) NOT NULL,
    [OUTSTANDING_DEPOSIT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_TASK_MAIN_OUTSTANDING_DEPOSIT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [CLIENT_NO]                      NVARCHAR (50)   NULL,
    [CLIENT_NAME]                    NVARCHAR (250)  NULL,
    [PROMISE_DATE]                   DATETIME        NULL,
    [DESKCOLL_STAFF_NAME]            NVARCHAR (220)  NULL,
    CONSTRAINT [PK_TASK_MAIN] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dari tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'TASK_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deskcollector pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'DESK_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor id deskcollection pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'DESKCOLL_MAIN_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode field collector pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'FIELD_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor id field collection pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'FIELDCOLL_MAIN_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses field collection tersebut - HOLD, menginformasikan bahwa data field collection tersebut belum diproses - POST, menginformasikan bahwa data field collection tersebut sudah diposting - CANCEL, menginformasikan bahwa data field collection tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'FIELD_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran terakhir yang dibayar pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_PAID_INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal jatuh tempo angsuran pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_DUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah periode keterlambataran kontrak pembiayaan pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari keterlambatan kontrak pembiayaan pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_DAYS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai denda keterlambatan pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_PENALTY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai keterlambatan angsuran pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa angsuran pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa deposit pada data tasklist tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TASK_MAIN', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_DEPOSIT_AMOUNT';

