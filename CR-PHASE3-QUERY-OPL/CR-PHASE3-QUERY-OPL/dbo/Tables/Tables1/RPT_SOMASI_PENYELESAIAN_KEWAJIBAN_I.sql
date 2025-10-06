CREATE TABLE [dbo].[RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_I] (
    [USER_ID]                NVARCHAR (50)  NOT NULL,
    [SURAT_NO]               NVARCHAR (50)  NULL,
    [NO_PERJANJIAN]          NVARCHAR (50)  NULL,
    [TANGGAL_PERJANJIAN]     DATETIME       NULL,
    [TIPE_KENDARAAN]         NVARCHAR (50)  NULL,
    [TAHUN_KENDARAAN]        NVARCHAR (4)   NULL,
    [NO_RANGKA]              NVARCHAR (50)  NULL,
    [NO_MESIN]               NVARCHAR (50)  NULL,
    [NO_POLISI]              NVARCHAR (50)  NULL,
    [MERK]                   NVARCHAR (250) NULL,
    [PERJANJIAN_PELAKSANAAN] NVARCHAR (250) NULL
);

