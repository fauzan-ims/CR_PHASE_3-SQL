CREATE TABLE [dbo].[INSURANCE_POLICY_MAIN_HISTORY] (
    [ID]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [POLICY_CODE]     NVARCHAR (50)   NOT NULL,
    [HISTORY_DATE]    DATETIME        NOT NULL,
    [HISTORY_TYPE]    NVARCHAR (50)   NOT NULL,
    [POLICY_STATUS]   NVARCHAR (20)   NOT NULL,
    [HISTORY_REMARKS] NVARCHAR (4000) NOT NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_POLICY_MAIN_HISTORY] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_INSURANCE_POLICY_MAIN_HISTORY_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_HISTORY', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada data history polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_HISTORY', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pada data history polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_HISTORY', @level2type = N'COLUMN', @level2name = N'HISTORY_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe history atas data history polis asuransi tersebut - ENDORSEMENT PAID, menginformasikan bahwa proses endorsement telah dibayar - ENDORSEMENT APPROVE,  menginformasikan bahwa proses endorsement telah disetujui - ENDORSEMENT ON PROCESS,  menginformasikan bahwa proses endorsement tersebut sedang dalam proses - ENTRY,  menginformasikan bahwa data polis asuransi tersebut baru terdaftar - TERMINATE PAID,  menginformasikan bahwa asuransi tersebut sudah di terminate dan sudah dibayar - CLAIM PAID, menginformasikan bahwa data polis asuransi tersebut dilakukan proses claim dan sudah dibayar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_HISTORY', @level2type = N'COLUMN', @level2name = N'HISTORY_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data polis asuransi tersebut - HOLD, menginformasikan bahwa polis asuransi tersebut belum diproses - ACTIVE, menginformasikan bahwa polis asuransi tersebut  sedang berstatus aktif - CLAIM, menginformasikan bahwa polis asuransi tersebut sedang dilakukan proses claim - APPROVE, menginformasikan bahwa claim asuransi tersebut telah disetujui', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_HISTORY', @level2type = N'COLUMN', @level2name = N'POLICY_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data history polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_HISTORY', @level2type = N'COLUMN', @level2name = N'HISTORY_REMARKS';

