CREATE TABLE [dbo].[RPT_INVOICE_PEMBATALAN_KONTRAK_KWITANSI] (
    [USER_ID]          NVARCHAR (50)   NOT NULL,
    [NO_KWITANSI]      NVARCHAR (50)   NULL,
    [SUDAH_TERIMA]     NVARCHAR (250)  NULL,
    [SEJUMLAH]         NVARCHAR (250)  NULL,
    [UNTUK_PEMBAYARAN] NVARCHAR (250)  NULL,
    [NO_PERJANJIAN]    NVARCHAR (50)   NULL,
    [JATUH_TEMPO]      DATETIME        NULL,
    [TOTAL]            DECIMAL (18, 2) NULL,
    [KOTA]             NVARCHAR (50)   NULL,
    [TANGGAL]          DATETIME        NULL,
    [NAMA]             NVARCHAR (50)   NULL,
    [JABATAN]          NVARCHAR (50)   NULL,
    [NAMA_BANK]        NVARCHAR (50)   NULL,
    [REK_ATAS_NAMA]    NVARCHAR (50)   NULL,
    [NO_REK]           NVARCHAR (50)   NULL
);

