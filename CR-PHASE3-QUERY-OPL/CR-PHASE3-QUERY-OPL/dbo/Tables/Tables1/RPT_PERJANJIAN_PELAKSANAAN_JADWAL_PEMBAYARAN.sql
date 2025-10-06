CREATE TABLE [dbo].[RPT_PERJANJIAN_PELAKSANAAN_JADWAL_PEMBAYARAN] (
    [USER_ID]                           NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]                    NVARCHAR (250)  NULL,
    [REPORT_TITLE]                      NVARCHAR (250)  NULL,
    [REPORT_IMAGE]                      NVARCHAR (250)  NULL,
    [TANGGAL_BAYAR]                     NVARCHAR (4000) NULL,
    [TANGGAL_SEWA_SATU]                 NVARCHAR (4000) NULL,
    [TANGGAL_PEMBAYARAN_AWAL_DAN_AKHIR] NVARCHAR (250)  NULL,
    [CREDIT_TERM]                       INT             NULL
);

