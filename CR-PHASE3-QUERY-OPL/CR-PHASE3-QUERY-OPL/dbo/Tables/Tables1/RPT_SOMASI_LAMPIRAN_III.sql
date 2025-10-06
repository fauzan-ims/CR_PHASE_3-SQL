CREATE TABLE [dbo].[RPT_SOMASI_LAMPIRAN_III] (
    [USER_ID]                  NVARCHAR (50)   NULL,
    [LETTER_NO]                NVARCHAR (50)   NULL,
    [NOMOR_PERJANJIAN]         NVARCHAR (50)   NULL,
    [NOMINAL_SEWA]             DECIMAL (18, 2) NULL,
    [TOTAL_HARI_KETERLAMBATAN] INT             NULL,
    [DENDA_SEWA]               DECIMAL (18, 2) NULL,
    [CRE_DATE]                 DATETIME        NULL,
    [CRE_BY]                   NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NULL,
    [MOD_DATE]                 DATETIME        NULL,
    [MOD_BY]                   NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NULL
);

