CREATE TABLE [dbo].[RPT_CONTRACT_LAMPIRAN_I] (
    [USER_ID]                     NVARCHAR (50)  NULL,
    [REPORT_COMPANY_NAME]         NVARCHAR (250) NULL,
    [REPORT_TITLE_LAMPIRAN_I]     NVARCHAR (250) NULL,
    [NOMOR_PERJANJIAN_INDUK]      NVARCHAR (50)  NULL,
    [NOMOR_PERJANJIAN_PELAKSANA]  NVARCHAR (50)  NULL,
    [TANGGAL_PERJANJIAN]          DATETIME       NULL,
    [CLIENT_NAME]                 NVARCHAR (250) NULL,
    [ASSET_NAME]                  NVARCHAR (250) NULL,
    [ASSET_YEAR]                  NVARCHAR (4)   NULL,
    [CHASSIS_NO]                  NVARCHAR (50)  NULL,
    [ENGINE_NO]                   NVARCHAR (50)  NULL,
    [SFESIFIKASI_AND_ACCESSORIES] NVARCHAR (400) NULL,
    [CRE_DATE]                    DATETIME       NULL,
    [CRE_BY]                      NVARCHAR (15)  NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)  NULL,
    [MOD_DATE]                    DATETIME       NULL,
    [MOD_BY]                      NVARCHAR (15)  NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)  NULL
);

