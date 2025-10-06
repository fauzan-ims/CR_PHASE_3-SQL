CREATE TABLE [dbo].[INSURANCE_REGISTER] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [REGISTER_NO]            NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [SOURCE_TYPE]            NVARCHAR (20)   NOT NULL,
    [REGISTER_TYPE]          NVARCHAR (10)   CONSTRAINT [DF_INSURANCE_REGISTER_REGISTER_TYPE] DEFAULT (N'NEW') NOT NULL,
    [POLICY_CODE]            NVARCHAR (50)   NULL,
    [REGISTER_STATUS]        NVARCHAR (10)   NOT NULL,
    [REGISTER_NAME]          NVARCHAR (250)  NOT NULL,
    [REGISTER_QQ_NAME]       NVARCHAR (250)  NOT NULL,
    [REGISTER_OBJECT_NAME]   NVARCHAR (250)  NOT NULL,
    [REGISTER_REMARKS]       NVARCHAR (4000) NOT NULL,
    [CURRENCY_CODE]          NVARCHAR (3)    NOT NULL,
    [INSURANCE_CODE]         NVARCHAR (50)   NULL,
    [INSURANCE_TYPE]         NVARCHAR (50)   NOT NULL,
    [EFF_RATE]               DECIMAL (9, 6)  NULL,
    [YEAR_PERIOD]            INT             NOT NULL,
    [IS_RENUAL]              NVARCHAR (1)    NOT NULL,
    [FROM_DATE]              DATETIME        NULL,
    [TO_DATE]                DATETIME        NULL,
    [INSURANCE_PAYMENT_TYPE] NVARCHAR (10)   NOT NULL,
    [INSURANCE_PAID_BY]      NVARCHAR (10)   NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [FLAG_DATE]              DATETIME        NULL,
    [BUDGET_STATUS]          NVARCHAR (4)    NULL,
    CONSTRAINT [PK_INSURANCE_REGISTER] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_INSURANCE_REGISTER_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor register pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe registrasi, New policy atau Add Asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pendaftaran pada proses pendaftaran asuransi tersebut - HOLD, menginformasikan bahwa proses pendaftaran asuransi tersebut belum diproses - ON PROCESS, menginformasikan bahwa proses pendaftaran asuransi tersebut sedang di proses - CANCEL, menginformasikan bahwa proses pendaftaran asuransi tersebut telah dibatalkan - PAID, menginformasikan bahwa proses pendaftaran asuransi tersebut telah dilakukan proses pembayaran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama yang dicover asuransi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama yang dibebankan atas polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_QQ_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama objek yang didaftarkan pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_OBJECT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode asuransi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'INSURANCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe asuransi pada proses pendaftaran asuransi tersebut - LIFE, menginformasikan bahwa asuransi tersebut merupakan asuransi jiwa - NON LIFE, menginformasikan bahwa asuransi tersebut bukan merupakan asuransi jiwa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'INSURANCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh maskapai asuransi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'EFF_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'YEAR_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah proses pendaftaran asuransi tersebut merupakan proses renewal?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'IS_RENUAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah masa berlaku polis asuransi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'FROM_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas berlakunya polis asuransi tersebut pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'TO_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pada proses pendaftaran asuransi tersebut - FULL TENOR FULL PAYMENT, menginformasikan bahwa customer membayar asuransi pertahun kepada multifinance dan multifinance membayar pertahun ke maskapai asuransi - FULL TENOR ANNUALLY PAYMENT, menginformasikan bahwa customer membayar asuransi pertahun kepada multifinance dan multifinance membayar perbulan ke maskapai asuransi - ANNUALLY TENOR ANNUALLY PAYMENT, menginformasikan bahwa customer membayar asuransi perbulan kepada multifinance dan multifinance membayar perbulan ke maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'INSURANCE_PAYMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang membayar asuransi tersebut - MULTIFINANCE, menginformasikan bahwa asuransi tersebut akan dibayar oleh multifinance - CLIENT, menginformasikan bahwa asuransi tersebut akan dibayar langsung oleh client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'INSURANCE_PAID_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER', @level2type = N'COLUMN', @level2name = N'CRE_DATE';

