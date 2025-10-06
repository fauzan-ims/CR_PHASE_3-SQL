CREATE TABLE [dbo].[temp_insurance_policy2] (
    [AGREEMENT_NO]               NVARCHAR (50)   NULL,
    [SEQ]                        INT             NULL,
    [CUSTOMER]                   NVARCHAR (250)  NULL,
    [ITEM_NAME]                  NVARCHAR (250)  NULL,
    [YEAR]                       NVARCHAR (4)    NULL,
    [CHASIS_NO]                  NVARCHAR (50)   NULL,
    [ENGINE_NO]                  NVARCHAR (50)   NULL,
    [PLAT_NO]                    NVARCHAR (50)   NULL,
    [TGL_EMAIL_SPPA]             DATETIME        NULL,
    [TANGGAL_PENERIMAAN_POLIS]   DATETIME        NULL,
    [NO_POLIS]                   NVARCHAR (50)   NULL,
    [END_POLIS_ASURANSI]         DATETIME        NULL,
    [TGL_JATUH_TEMPO_PEMBAYARAN] DATETIME        NULL,
    [NET_PREMI]                  DECIMAL (18, 2) NULL,
    [SISA_BUDGET]                DECIMAL (18, 2) NULL,
    [TGL_KIRIM_KE_AP]            DATETIME        NULL,
    [TGL_BAYAR_KE_ASURANSI]      DATETIME        NULL,
    [KETERANGAN]                 NVARCHAR (250)  NULL
);

