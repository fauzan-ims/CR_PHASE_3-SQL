CREATE TABLE [dbo].[RPT_SURAT_PERINGATAN_I_LAMPIRAN_I] (
    [USER_ID]                  NVARCHAR (50)  NULL,
    [NOMOR_SURAT]              NVARCHAR (50)  NULL,
    [TANGGAL_SURAT_PERINGATAN] DATETIME       NULL,
    [AGREEMENT_NO]             NVARCHAR (50)  NULL,
    [MAIN_CONTRACT_NO]         NVARCHAR (50)  NULL,
    [YEAR]                     NVARCHAR (4)   NULL,
    [CHASSIS_NO]               NVARCHAR (50)  NULL,
    [ENGINE_NO]                NVARCHAR (50)  NULL,
    [CRE_DATE]                 DATETIME       NULL,
    [CRE_BY]                   NVARCHAR (15)  NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)  NULL,
    [MOD_DATE]                 DATETIME       NULL,
    [MOD_BY]                   NVARCHAR (15)  NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)  NULL,
    [AGREEMENT_DATE]           DATETIME       NULL,
    [ASSET_NAME]               NVARCHAR (250) NULL,
    [VEHICLE_TYPE]             NVARCHAR (50)  NULL,
    [BRAND]                    NVARCHAR (50)  NULL,
    [PLAT_NO]                  NVARCHAR (50)  NULL
);

