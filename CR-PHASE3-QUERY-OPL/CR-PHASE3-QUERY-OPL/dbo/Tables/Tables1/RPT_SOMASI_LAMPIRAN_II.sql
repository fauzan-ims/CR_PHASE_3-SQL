CREATE TABLE [dbo].[RPT_SOMASI_LAMPIRAN_II] (
    [USER_ID]             NVARCHAR (50)   NULL,
    [LETTER_NO]           NVARCHAR (50)   NULL,
    [NOMOR_PERJANJIAN]    NVARCHAR (50)   NULL,
    [NOMINAL_SEWA]        DECIMAL (18, 2) NULL,
    [PERIODE_SEWA]        NVARCHAR (50)   NULL,
    [NOMOR_INVOICE]       NVARCHAR (50)   NULL,
    [NOMINAL_INVOICE]     DECIMAL (18, 2) NULL,
    [TANGGAL_JATUH_TEMPO] DATETIME        NULL,
    [CRE_DATE]            DATETIME        NULL,
    [CRE_BY]              NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NULL,
    [MOD_DATE]            DATETIME        NULL,
    [MOD_BY]              NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NULL
);

