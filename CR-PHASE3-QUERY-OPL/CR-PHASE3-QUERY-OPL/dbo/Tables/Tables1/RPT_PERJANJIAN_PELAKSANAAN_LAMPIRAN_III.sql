CREATE TABLE [dbo].[RPT_PERJANJIAN_PELAKSANAAN_LAMPIRAN_III] (
    [USER_ID]                        NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]                 NVARCHAR (250)  NULL,
    [REPORT_TITLE]                   NVARCHAR (250)  NULL,
    [REPORT_IMAGE]                   NVARCHAR (250)  NULL,
    [NO_INDUK]                       NVARCHAR (50)   NULL,
    [NO_PELAKSANAAN]                 NVARCHAR (50)   NULL,
    [TANGGAL_PERJANJIAN]             NVARCHAR (50)   NULL,
    [NAMA_LESSEE]                    NVARCHAR (250)  NULL,
    [NAMA_BARANG]                    NVARCHAR (250)  NULL,
    [TAHUN]                          NVARCHAR (4)    NULL,
    [NO_RANGKA]                      NVARCHAR (50)   NULL,
    [NO_MESIN]                       NVARCHAR (50)   NULL,
    [SPESIFIKASI]                    NVARCHAR (250)  NULL,
    [AKSESORIS]                      NVARCHAR (250)  NULL,
    [NO_POLISI]                      NVARCHAR (10)   NULL,
    [TANGGAL_BAST]                   DATETIME        NULL,
    [LOKASI_PENYERAHAN_PENGEMBALIAN] NVARCHAR (4000) NULL,
    [EMPLOYEE_LESSOR]                NVARCHAR (50)   NULL
);

