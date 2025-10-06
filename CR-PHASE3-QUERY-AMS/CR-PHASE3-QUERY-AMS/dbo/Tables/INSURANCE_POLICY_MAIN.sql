CREATE TABLE [dbo].[INSURANCE_POLICY_MAIN] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [SPPA_CODE]              NVARCHAR (50)   NULL,
    [REGISTER_CODE]          NVARCHAR (50)   NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [SOURCE_TYPE]            NVARCHAR (20)   NULL,
    [POLICY_STATUS]          NVARCHAR (10)   NOT NULL,
    [POLICY_PAYMENT_STATUS]  NVARCHAR (10)   NOT NULL,
    [INSURED_NAME]           NVARCHAR (250)  NOT NULL,
    [INSURED_QQ_NAME]        NVARCHAR (250)  NOT NULL,
    [POLICY_PAYMENT_TYPE]    NVARCHAR (5)    NOT NULL,
    [OBJECT_NAME]            NVARCHAR (4000) NOT NULL,
    [INSURANCE_CODE]         NVARCHAR (50)   CONSTRAINT [DF_INSURANCE_POLICY_MAIN_INSURANCE_CODE] DEFAULT ((0)) NOT NULL,
    [INSURANCE_TYPE]         NVARCHAR (10)   NOT NULL,
    [CURRENCY_CODE]          NVARCHAR (3)    NOT NULL,
    [COVER_NOTE_NO]          NVARCHAR (50)   NULL,
    [COVER_NOTE_DATE]        DATETIME        NULL,
    [POLICY_NO]              NVARCHAR (50)   NULL,
    [POLICY_EFF_DATE]        DATETIME        NULL,
    [POLICY_EXP_DATE]        DATETIME        NULL,
    [EFF_RATE]               DECIMAL (9, 6)  NULL,
    [FILE_NAME]              NVARCHAR (250)  CONSTRAINT [DF_INSURANCE_POLICY_MAIN_FILE_NAME] DEFAULT (N'') NULL,
    [PATHS]                  NVARCHAR (250)  CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PATHS] DEFAULT (N'') NULL,
    [DOC_FILE]               VARBINARY (MAX) NULL,
    [INVOICE_NO]             NVARCHAR (50)   NULL,
    [INVOICE_DATE]           DATETIME        NULL,
    [FAKTUR_NO]              NVARCHAR (50)   NULL,
    [FROM_YEAR]              INT             CONSTRAINT [DF_INSURANCE_POLICY_MAIN_FROM_YEAR] DEFAULT ((0)) NOT NULL,
    [TO_YEAR]                INT             CONSTRAINT [DF_INSURANCE_POLICY_MAIN_TO_YEAR] DEFAULT ((0)) NOT NULL,
    [TOTAL_PREMI_BUY_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_TOTAL_PREMI_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_DISCOUNT_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_TOTAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_NET_PREMI_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_TOTAL_NET_PREMI_AMOUNT] DEFAULT ((0)) NOT NULL,
    [STAMP_FEE_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_STAMP_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADMIN_FEE_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_ADMIN_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_ADJUSMENT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_TOTAL_ADJUSMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [IS_POLICY_EXISTING]     NVARCHAR (1)    CONSTRAINT [DF_INSURANCE_POLICY_MAIN_ENDORSEMENT_COUNT1] DEFAULT ((0)) NOT NULL,
    [ENDORSEMENT_COUNT]      INT             CONSTRAINT [DF_INSURANCE_POLICY_MAIN_ENDORSEMENT_COUNT] DEFAULT ((0)) NOT NULL,
    [POLICY_PROCESS_STATUS]  NVARCHAR (20)   NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [FAKTUR_DATE]            DATETIME        NULL,
    [PRINT_COUNT]            INT             NULL,
    [ASSET_FAKTUR_NO]        NVARCHAR (50)   NULL,
    [ASSET_INVOICE_NO]       NVARCHAR (50)   NULL,
    [RETURN_REASON]          NVARCHAR (4000) NULL,
    CONSTRAINT [PK_INSURANCE_POLICY_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode SPPA pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'SPPA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada polis asuransi tersebut - ACTIVE, menginformasikan bahwa data polis asuransi tersebut sedang aktif - INACTIVE, menginformasikan bahwa data polis asuransi tersebut sedang tidak aktif - TERMINATE, menginformasikan bahwa data polias asuransi tersebut sudah dilakukan proses terminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pembayaran pada polis asuransi tersebut - HOLD, menginformasikan bahwa pembayaran atas polis asuransi tersebut belum diproses - ON PROCESS, menginformasikan bahwa pembayaran atas polis asuransi tersebut sedang dalam proses pembayaran - PAID, menginformasikan bahwa pembayaran atas polis asuransi tersebut sudah dilakukan proses pembayaran - CANCEL, menginformasikan bahwa pembayaran atas polis asuransi tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_PAYMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama yang dicover oleh maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'INSURED_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pihak yang dibebankan pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'INSURED_QQ_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pada polis asuransi tersebut - FULL TENOR FULL PAYMENT, menginformasikan bahwa customer membayar ke multifinance per tahun dan multifinance membayar ke maskapai juga per tahun - FULL TENOR ANNUALLY PAYMENT, menginformasikan bahwa customer membayar ke multifinance per tahun dan multifinance membayar ke maskapai per bulan - ANNUALLY TENOR ANNYALLY PAYMENT, menginformasikan bahwa customer membayar ke multifinance per bulan dan multifinance membayar ke maskapai juga per bulan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_PAYMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama objek yang diasuransikan pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'OBJECT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode asuransi pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'INSURANCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe asuransi pada polis asuransi tersebut - LIFE, menginformasikan bahwa asuransi tersebut merupakan asuransi jiwa - NON LIFE, menginformasikan bahwa asuransi tersebut bukan merupakan asuransi jiwa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'INSURANCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor cover note pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'COVER_NOTE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal covernote pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'COVER_NOTE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor polis asuransi pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal effektif polis pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_EFF_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa polis pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_EXP_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor invoice pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'INVOICE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal invoice pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'INVOICE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah periode tahun pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'FROM_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas periode tahun pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'TO_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total premi beli asuransi pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'TOTAL_PREMI_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total diskon asuransi pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'TOTAL_DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total premi beli asuransi setelah dikurangi nilai diskon pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'TOTAL_NET_PREMI_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai materai pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'STAMP_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya admin pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'ADMIN_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total adjustment pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'TOTAL_ADJUSMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah customer sudah memiliki polis asuransi sendiri?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'IS_POLICY_EXISTING';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomonal count endorsement pada polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status proses pada polis asuransi tersebut - CLAIM,menginformasikan bahwa polis asuransi tersebut dilakukan proses claim - ENDORSEMENT, menginformasikan bahwa polis asuransi tersebut dilakukan proses endorsement - TERMINATE, menginformasikan bahwa polis asuransi tersebut dilakukan proses terminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN', @level2type = N'COLUMN', @level2name = N'POLICY_PROCESS_STATUS';

