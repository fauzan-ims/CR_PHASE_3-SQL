CREATE TABLE [dbo].[RPT_LIST_FAKTUR_PAJAK_INSURANCE_DETAIL_DETAIL] (
    [USER_ID]           NVARCHAR (50)   NULL,
    [KODE_OBJEK]        NVARCHAR (50)   NULL,
    [NAMA_TRX]          NVARCHAR (4000) NULL,
    [HARGA_SATUAN]      DECIMAL (18, 2) NULL,
    [JUMLAH_BARANG]     INT             NULL,
    [HARGA_TOTAL]       DECIMAL (18, 2) NULL,
    [DISKON]            DECIMAL (18, 2) NULL,
    [DPP]               DECIMAL (18, 2) NULL,
    [PPN]               DECIMAL (18, 2) NULL,
    [TARIF_PPNBM]       DECIMAL (18, 2) NULL,
    [PPNBM]             DECIMAL (18, 2) NULL,
    [INVOICE_CODE]      NVARCHAR (50)   NULL,
    [JUMLAH_BARANG_STR] NVARCHAR (50)   NULL,
    [REFERENSI]         NVARCHAR (50)   NULL
);

