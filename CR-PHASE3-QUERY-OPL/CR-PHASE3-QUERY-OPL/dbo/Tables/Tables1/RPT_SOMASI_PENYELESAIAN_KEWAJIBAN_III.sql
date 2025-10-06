CREATE TABLE [dbo].[RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_III] (
    [USER_ID]                  NVARCHAR (50)   NOT NULL,
    [SURAT_NO]                 NVARCHAR (50)   NULL,
    [NO_PERJANJIAN]            NVARCHAR (50)   NULL,
    [NOMINAL_SEWA]             DECIMAL (18, 2) NULL,
    [TOTAL_HARI_KETERLAMBATAN] INT             NULL,
    [DENDA_SEWA]               DECIMAL (18, 2) NULL
);

