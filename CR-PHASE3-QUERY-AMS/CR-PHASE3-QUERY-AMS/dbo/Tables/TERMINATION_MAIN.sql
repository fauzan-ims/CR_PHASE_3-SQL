CREATE TABLE [dbo].[TERMINATION_MAIN] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [POLICY_CODE]                 NVARCHAR (50)   NOT NULL,
    [TERMINATION_STATUS]          NVARCHAR (10)   NOT NULL,
    [TERMINATION_DATE]            DATETIME        NOT NULL,
    [TERMINATION_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_TERMINATION_MAIN_TERMINATE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TERMINATION_APPROVED_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_TERMINATION_MAIN_TERMINATE_APPROVE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TERMINATION_REMARKS]         NVARCHAR (4000) NOT NULL,
    [TERMINATION_REQUEST_CODE]    NVARCHAR (50)   NULL,
    [RECEIVED_REQUEST_CODE]       NVARCHAR (50)   NULL,
    [TERMINATION_REASON_CODE]     NVARCHAR (50)   NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_TERMINATION_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_TERMINATION_MAIN_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_TERMINATION_MAIN_TERMINATION_REQUEST1] FOREIGN KEY ([TERMINATION_REQUEST_CODE]) REFERENCES [dbo].[TERMINATION_REQUEST] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi yang akan diterminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses terminate asuransi tersebut - HOLD, menginformasikan bahwa proses terminate asuransi tersebut belum diproses - ON PROCESS, menginformasikan bahwa proses terminate asuransi tersebut sedang di proses - APPROVE, menginformasikan bahwa proses terminate asuransi tersebut telah disetujui - CANCEL, menginformasikan bahwa proses terminate asuransi tersebut telah dibatalkan - REJECT, menginformasikan bahwa proses terminate asuransi tersebut telah ditolak - PAID, menginformasikan bahwa proses terminate asuransi tersebut telah dilakukan pembayaran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal asuransi tersebut dilakukan proses terminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biaya yang harus dibayarkan pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biaya yang disetujui pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_APPROVED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode received request pada proses terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';

