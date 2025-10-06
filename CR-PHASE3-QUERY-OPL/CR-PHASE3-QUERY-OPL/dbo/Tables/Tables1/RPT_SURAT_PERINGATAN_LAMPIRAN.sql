CREATE TABLE [dbo].[RPT_SURAT_PERINGATAN_LAMPIRAN] (
    [USER_ID]                             NVARCHAR (50)   NULL,
    [NOMOR_SURAT]                         NVARCHAR (50)   NULL,
    [TANGGAL_SURAT_PERINGATAN]            DATETIME        NULL,
    [INVOICE_NO]                          NVARCHAR (50)   NULL,
    [AGREEMENT_NO]                        NVARCHAR (50)   NULL,
    [MAIN_CONTRACT_NO]                    NVARCHAR (50)   NULL,
    [ASSET_NAME]                          NVARCHAR (250)  NULL,
    [BRAND]                               NVARCHAR (50)   NULL,
    [YEAR]                                NVARCHAR (4)    NULL,
    [PERIODE_PEMAKAIAN]                   NVARCHAR (4000) NULL,
    [AMOUNT]                              DECIMAL (18, 2) NULL,
    [DUE_DATE_INVOICE]                    DATETIME        NULL,
    [DENDA_KETERLAMBATAN_PEMBAYARAN_SEWA] DECIMAL (18, 2) NULL,
    [STATUS]                              NVARCHAR (50)   NULL,
    [CRE_DATE]                            DATETIME        NULL,
    [CRE_BY]                              NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]                      NVARCHAR (15)   NULL,
    [MOD_DATE]                            DATETIME        NULL,
    [MOD_BY]                              NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]                      NVARCHAR (15)   NULL,
    [HARI_KETERLAMBATAN]                  INT             NULL
);

