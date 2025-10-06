CREATE TABLE [dbo].[TEMP_INSURANCE_NEW_4] (
    [AGREEMENT_NUMBER]     NVARCHAR (50)   NULL,
    [CUSTOMER]             NVARCHAR (250)  NULL,
    [OBJECT_LEASED]        NVARCHAR (250)  NULL,
    [YEAR]                 INT             NULL,
    [CHASIS_NUMBER]        NVARCHAR (50)   NULL,
    [ENGINE_NUMBER]        NVARCHAR (50)   NULL,
    [POLICE_NUMBER]        NVARCHAR (50)   NULL,
    [TGL_EMAIL_SPPA]       DATETIME        NULL,
    [TGL_PENERIMAAN_POLIS] DATETIME        NULL,
    [NO_POLIS]             NVARCHAR (50)   NULL,
    [START_POLIS]          DATETIME        NULL,
    [END_POLIS_ASURANSI]   DATETIME        NULL,
    [NET_PREMI]            DECIMAL (18, 2) NULL,
    [KETERANGAN]           NVARCHAR (250)  NULL,
    [PERIODE]              INT             NULL
);

