CREATE TABLE [dbo].[TEMP_INSURANCE_31_JAN] (
    [AGREEMENT_NUMBER]     NVARCHAR (50)   NULL,
    [CUSTOMER]             NVARCHAR (250)  NULL,
    [OBJECT_LEASED]        NVARCHAR (250)  NULL,
    [KAROSERI]             NVARCHAR (250)  NULL,
    [YEAR]                 INT             NULL,
    [CHASIS_NUMBER]        NVARCHAR (50)   NULL,
    [ENGINE_NUMBER]        NVARCHAR (50)   NULL,
    [POLICE_NUMBER]        NVARCHAR (50)   NULL,
    [TGL_EMAIL_SPPA]       DATETIME        NULL,
    [TGL_PENERIMAAN_POLIS] DATETIME        NULL,
    [NO_POLIS]             NVARCHAR (50)   NULL,
    [BULAN]                INT             NULL,
    [JANGKA_WAKTU]         NVARCHAR (50)   NULL,
    [START_POLIS]          DATETIME        NULL,
    [END_POLIS_ASURANSI]   DATETIME        NULL,
    [NILAI_PERTANGGUNGAN]  DECIMAL (18, 2) NULL,
    [NET_PREMI]            DECIMAL (18, 2) NULL,
    [PERIODE]              INT             NULL,
    [KONDISI]              NVARCHAR (250)  NULL
);

