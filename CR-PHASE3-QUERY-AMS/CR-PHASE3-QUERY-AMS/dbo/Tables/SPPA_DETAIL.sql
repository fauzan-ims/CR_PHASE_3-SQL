CREATE TABLE [dbo].[SPPA_DETAIL] (
    [ID]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [SPPA_CODE]               NVARCHAR (50)   NOT NULL,
    [SPPA_REQUEST_CODE]       NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FA_CODE]                 NVARCHAR (50)   NULL,
    [INSURED_NAME]            NVARCHAR (250)  NOT NULL,
    [OBJECT_NAME]             NVARCHAR (4000) NOT NULL,
    [CURRENCY_CODE]           NVARCHAR (3)    NOT NULL,
    [SUM_INSURED_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [FROM_YEAR]               INT             CONSTRAINT [DF_SPPA_DETAIL_FROM_YEAR] DEFAULT ((0)) NOT NULL,
    [TO_YEAR]                 INT             CONSTRAINT [DF_SPPA_DETAIL_TO_YEAR] DEFAULT ((0)) NOT NULL,
    [RESULT_STATUS]           NVARCHAR (20)   NULL,
    [RESULT_DATE]             DATETIME        NULL,
    [RESULT_TOTAL_BUY_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_SPPA_DETAIL_RESULT_PREMI_AMOUNT] DEFAULT ((0)) NOT NULL,
    [RESULT_POLICY_NO]        NVARCHAR (50)   NULL,
    [RESULT_REASON]           NVARCHAR (4000) NULL,
    [CRE_DATE]                DATETIME        NOT NULL,
    [CRE_BY]                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                DATETIME        NOT NULL,
    [MOD_BY]                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [ACCESSORIES]             NVARCHAR (4000) NULL,
    CONSTRAINT [PK_INSURANCE_SPPA_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_SPPA_DETAIL_ASSET] FOREIGN KEY ([FA_CODE]) REFERENCES [dbo].[ASSET] ([CODE]),
    CONSTRAINT [FK_SPPA_DETAIL_SPPA_MAIN] FOREIGN KEY ([SPPA_CODE]) REFERENCES [dbo].[SPPA_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_SPPA_DETAIL_SPPA_REQUEST] FOREIGN KEY ([SPPA_REQUEST_CODE]) REFERENCES [dbo].[SPPA_REQUEST] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode SPPA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'SPPA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'SPPA_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'FA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama maskapai asuransi pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'INSURED_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama objek yang dicover oleh asuransi pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'OBJECT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh maskapai pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah tahun asuransi pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'FROM_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas tahun asuransi pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'TO_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari hasil proses SPPA tersebut - ON PROCESS, menginformasikan bahwa data SPPA tersebut sedang dalam proses - APPROVE, menginformasikan bahwa data SPPA tersebut sudah disetujui - REJECT, menginformasikan bahwa data SPPA tersebut telah ditolak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal hasil SPPA tersebut keluar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total beli asuransi dari maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_TOTAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor policy pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_POLICY_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alasan atau catatan dari hasil SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_REASON';

