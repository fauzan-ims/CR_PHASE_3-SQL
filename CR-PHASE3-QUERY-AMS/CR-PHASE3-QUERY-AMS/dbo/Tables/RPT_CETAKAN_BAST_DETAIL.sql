CREATE TABLE [dbo].[RPT_CETAKAN_BAST_DETAIL] (
    [USER_ID]             NVARCHAR (50)   NULL,
    [FILTER_TYPE]         NVARCHAR (50)   NULL,
    [FILTER_AGREEMENT_NO] NVARCHAR (50)   NULL,
    [REPORT_TITLE]        NVARCHAR (250)  NULL,
    [DESCRIPTION]         NVARCHAR (250)  NULL,
    [JENIS_BARANG]        NVARCHAR (100)  NULL,
    [NO_BARCODE]          NVARCHAR (100)  NULL,
    [MERK]                NVARCHAR (50)   NULL,
    [JENIS]               NVARCHAR (50)   NULL,
    [TYPE]                NVARCHAR (50)   NULL,
    [JUMLAH_UNIT]         INT             NULL,
    [TAHUN]               NVARCHAR (4)    NULL,
    [JUMLAH_ASSET]        INT             NULL,
    [HARGA_PEROLEHAN]     DECIMAL (18, 2) NULL,
    [NILAL_BUKU]          DECIMAL (18, 2) NULL
);

