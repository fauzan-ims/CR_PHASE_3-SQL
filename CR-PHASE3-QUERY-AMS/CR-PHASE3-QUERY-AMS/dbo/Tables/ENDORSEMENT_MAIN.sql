CREATE TABLE [dbo].[ENDORSEMENT_MAIN] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [ENDORSEMENT_STATUS]          NVARCHAR (10)   NOT NULL,
    [ENDORSEMENT_DATE]            DATETIME        NULL,
    [POLICY_CODE]                 NVARCHAR (50)   NOT NULL,
    [ENDORSEMENT_TYPE]            NVARCHAR (15)   NULL,
    [ENDORSEMENT_REMARKS]         NVARCHAR (4000) NOT NULL,
    [ENDORSEMENT_REQUEST_CODE]    NVARCHAR (50)   NULL,
    [CURRENCY_CODE]               NVARCHAR (3)    NOT NULL,
    [ENDORSEMENT_PAYMENT_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_MAIN_ENDORSEMENT_RECEIVE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [ENDORSEMENT_RECEIVED_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_MAIN_ENDORSEMENT_RECEIVED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PAYMENT_REQUEST_CODE]        NVARCHAR (50)   NULL,
    [RECEIVED_REQUEST_CODE]       NVARCHAR (50)   NULL,
    [ENDORSEMENT_REASON_CODE]     NVARCHAR (50)   NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ENDORSEMENT_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_ENDORSEMENT_MAIN_ENDORSEMENT_REQUEST] FOREIGN KEY ([ENDORSEMENT_REQUEST_CODE]) REFERENCES [dbo].[ENDORSEMENT_REQUEST] ([CODE]),
    CONSTRAINT [FK_ENDORSEMENT_MAIN_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses endorsement tersebut - HOLD, menginformasikan bahwa data endorsement tersebut belum di proses - ON PROCESS, menginformasikan bahwa data asuransi tersebut sedang dalam proses endorsement - APPROVE, menginformasikan bahwa data endorsement tersebut sudah disetujui - REJECT, menginformasikan bahwa data endorsement tersebut telah ditolak - PAID, menginformasikan bahwa data endorsement tersebut telah dilakukan proses pembayaran - CANCEL, menginformasikan bahwa data endorsement tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses endorsement pada proses endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe endorsement pada proses endorsement asuransi tersebut - FINANCIAL, menginformasikan bahwa endorsement yang dilakukan berhubungan dengan nominal uang - NON FINANCIAL, menginformasikan bahwa endorsement yang dilakukan tidak berhubungan dengan nominal uang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nominal yang dibayarkan ke maskapai asuransi pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_PAYMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nominal yang diterima dari customer pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_RECEIVED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode payment request pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'PAYMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request penerimaan pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';

