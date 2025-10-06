CREATE TABLE [dbo].[WARNING_LETTER] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [LETTER_STATUS]               NVARCHAR (20)   NOT NULL,
    [LETTER_DATE]                 DATETIME        NOT NULL,
    [LETTER_NO]                   NVARCHAR (50)   NOT NULL,
    [LETTER_TYPE]                 NVARCHAR (10)   NOT NULL,
    [LETTER_REMARKS]              NVARCHAR (4000) NULL,
    [AGREEMENT_NO]                NVARCHAR (50)   NULL,
    [MAX_PRINT_COUNT]             INT             NOT NULL,
    [PRINT_COUNT]                 INT             CONSTRAINT [DF_COLLECTION_LETTER_PRINT_COUNT] DEFAULT ((0)) NOT NULL,
    [LAST_PRINT_BY]               NVARCHAR (50)   NULL,
    [GENERATE_TYPE]               NVARCHAR (10)   CONSTRAINT [DF_COLLECTION_LETTER_GENERATE_TYPE] DEFAULT (N'SYSTEM') NOT NULL,
    [PREVIOUS_LETTER_CODE]        NVARCHAR (50)   NULL,
    [INSTALLMENT_AMOUNT]          DECIMAL (18, 2) NOT NULL,
    [OVERDUE_DAYS]                INT             CONSTRAINT [DF_COLLECTION_LETTER_OVERDUE_DAYS] DEFAULT ((0)) NULL,
    [INSTALLMENT_NO]              INT             CONSTRAINT [DF_WARNING_LETTER_LAST_PAID_INSTALLMENT_NO] DEFAULT ((0)) NULL,
    [OVERDUE_PENALTY_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_COLLECTION_LETTER_OVERDUE_PENALTY] DEFAULT ((0)) NOT NULL,
    [OVERDUE_INSTALLMENT_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_COLLECTION_LETTER_OVERDUE_INSTALLMENT] DEFAULT ((0)) NOT NULL,
    [DELIVERY_CODE]               NVARCHAR (50)   NULL,
    [DELIVERY_DATE]               DATETIME        NULL,
    [RECEIVED_BY]                 NVARCHAR (250)  NULL,
    [RECEIVED_DATE]               DATETIME        NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [CLIENT_NO]                   NVARCHAR (50)   NULL,
    [TOTAL_AGREEMENT_COUNT]       BIGINT          NULL,
    [TOTAL_ASSET_COUNT]           BIGINT          NULL,
    [TOTAL_MONTHLY_RENTAL_AMOUNT] DECIMAL (18, 2) NULL,
    [CLIENT_NAME]                 NVARCHAR (250)  NULL,
    [TOTAL_OVERDUE_AMOUNT]        DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_WARNING_LETTER] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_WARNING_LETTER_20240320]
    ON [dbo].[WARNING_LETTER]([LETTER_TYPE] ASC, [AGREEMENT_NO] ASC, [LETTER_STATUS] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_WARNING_LETTER_AGREEMENT_NO_20240320]
    ON [dbo].[WARNING_LETTER]([DELIVERY_CODE] ASC)
    INCLUDE([AGREEMENT_NO]);


GO
CREATE NONCLUSTERED INDEX [DX_LETTER_TYPE_20240320]
    ON [dbo].[WARNING_LETTER]([LETTER_TYPE] ASC)
    INCLUDE([LETTER_DATE], [LETTER_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_LETTER_DATE_20240320]
    ON [dbo].[WARNING_LETTER]([LETTER_NO] ASC, [LETTER_TYPE] ASC)
    INCLUDE([LETTER_DATE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CREATE, PRINT, REQUEST, ALREADY PAID, ON DELIVERY, DELIVER, NOT DELIVER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor surat pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe surat peringatan tersebut - SP1, menginformasikan bahwa surat tersebut merupakan surat peringatan 1 - SP2, menginformasikan bahwa surat tersebut merupakan surat peringatan 2 - SP3, menginformasikan bahwa surat tersebut merupakan surat peringatan 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'LETTER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas maksimal surat peringatan boleh dicetak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'MAX_PRINT_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Berapa kali surat peringatan tersebut sudah dilakukan proses cetak', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'PRINT_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pihak yang terakhir melakukan proses cetak surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'LAST_PRINT_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pada proses generate surat peringatan tersebut - AUTOMATIC, menginformasikan bahwa surat peringatan tersebut di generate secara otomatis oleh sistem - MANUAL, menginformasikan bahwa surat peringatan tersebut di generate secara manual oleh user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'GENERATE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode surat peringatan sebelumnya yang telah dikirim', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'PREVIOUS_LETTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai angsuran kontrak pembiayaan yang dikirim surat peringatan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah keterlambatan hari pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'OVERDUE_DAYS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran terakhir yang dibayar pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai denda keterlambatan pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'OVERDUE_PENALTY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai keterlambatan angsuran pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'OVERDUE_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pengiriman pada surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'DELIVERY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal surat peringatan tersebut dikirim', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'DELIVERY_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'RECEIVED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal surat peringatan tersebut diterima', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER', @level2type = N'COLUMN', @level2name = N'RECEIVED_DATE';

