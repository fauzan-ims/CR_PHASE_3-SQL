CREATE TABLE [dbo].[XXX_RPT_INVOICE_PENAGIHAN_DETAIL_ASSET_20250904] (
    [USER_ID]        NVARCHAR (50)   NOT NULL,
    [JENIS]          NVARCHAR (250)  NULL,
    [CODE]           NVARCHAR (50)   NULL,
    [TYPE]           NVARCHAR (250)  NULL,
    [URAIAN]         NVARCHAR (250)  NULL,
    [JUMLAH]         INT             NULL,
    [HARGA_PERUNIT]  DECIMAL (18, 2) NULL,
    [JUMLAH_HARGA]   DECIMAL (18, 2) NULL,
    [SUB_TOTAL]      DECIMAL (18, 2) NULL,
    [PPN]            DECIMAL (18, 2) NULL,
    [PPN_RATE]       DECIMAL (9, 6)  NULL,
    [TOTAL]          DECIMAL (18, 2) NULL,
    [INVOICE_NO]     NVARCHAR (50)   NULL,
    [DPP_NILAI_LAIN] DECIMAL (18, 2) NULL
);

