CREATE TABLE [dbo].[CLAIM_MAIN] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [POLICY_CODE]            NVARCHAR (50)   NOT NULL,
    [CLAIM_STATUS]           NVARCHAR (10)   NOT NULL,
    [CLAIM_PROGRESS_STATUS]  NVARCHAR (10)   NOT NULL,
    [CLAIM_AMOUNT]           DECIMAL (18, 2) NOT NULL,
    [CLAIM_REMARKS]          NVARCHAR (4000) NOT NULL,
    [CLAIM_REFF_EXTERNAL_NO] NVARCHAR (50)   NOT NULL,
    [CLAIM_LOSS_TYPE]        NVARCHAR (50)   NOT NULL,
    [IS_POLICY_TERMINATE]    NVARCHAR (1)    CONSTRAINT [DF_CLAIM_MAIN_IS_POLICY_TERMINATE] DEFAULT ((0)) NOT NULL,
    [IS_EX_GRATIA]           NVARCHAR (1)    CONSTRAINT [DF_CLAIM_MAIN_IS_POLICY_TERMINATE1] DEFAULT ((0)) NOT NULL,
    [CLAIM_REQUEST_CODE]     NVARCHAR (50)   NULL,
    [LOSS_DATE]              DATETIME        NOT NULL,
    [CUSTOMER_REPORT_DATE]   DATETIME        NOT NULL,
    [FINANCE_REPORT_DATE]    DATETIME        NULL,
    [RESULT_REPORT_DATE]     DATETIME        NULL,
    [RECEIVED_REQUEST_CODE]  NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_NO]    NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_DATE]  DATETIME        NULL,
    [CLAIM_REASON_CODE]      NVARCHAR (50)   NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [ASSET_INFO]             NVARCHAR (4000) NULL,
    [FILE_NAME]              NVARCHAR (250)  NULL,
    [FILE_PATH]              NVARCHAR (250)  NULL,
    CONSTRAINT [PK_INSURANCE_CLAIM_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CLAIM_MAIN_CLAIM_REQUEST] FOREIGN KEY ([CLAIM_REQUEST_CODE]) REFERENCES [dbo].[CLAIM_REQUEST] ([CODE]),
    CONSTRAINT [FK_CLAIM_MAIN_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses claim asuransi tersebut - HOLD, menginformasikan bahwa data claim asuransi tersebut belum diproses - ON PROCESS, menginformasikan bahwa data claim asuransi tersebut sedang di proses - APPROVE, menginformasikan bahwa data claim asuransi tersebut telah disetujui - CANCEL, menginformasikan bahwa data claim asuransi tersebut telah dibatalkan - REJECT, menginformasikan bahwa data claim asuransi tersebut telah ditolak - PAID, menginformasikan bahwa data claim asuransi tersebut telah dilakukan pembayaran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status progress claim menginformasikan bahwa data claim asuransi tersebut - ENTRY, menginformasikan bahwa proses claim asuransi tersebut baru didaftarkan - ON PROCESS, menginformasikan bahwa proses claim asuransi tersebut sedang dalam proses - FOLLOW UP, menginformasikan bahwa proses claim asuransi tersebut telah dilakukan proses follow up - APPROVE, menginformasikan bahwa proses claim asuransi tersebut telah disetujui - REJECT, menginformasikan bahwa proses claim asuransi tersebut telah ditolak - CANCEL, menginformasikan bahwa proses claim asuransi tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_PROGRESS_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai claim pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi claim external pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_REFF_EXTERNAL_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe claim loss pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_LOSS_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data polis asuransi tersebut dilakukan proses terminate?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'IS_POLICY_TERMINATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah polis asuransi tersebut berstatus ex gratia?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'IS_EX_GRATIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode claim request pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CLAIM_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kerugian pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'LOSS_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal customer melaporkan proses claim pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'CUSTOMER_REPORT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal finance melaporkan proses claim pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'FINANCE_REPORT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal hasil claim asuransi pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'RESULT_REPORT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request penerimaan pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor voucher proses penerimaan pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal voucher penerimaan pada proses claim asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_DATE';

