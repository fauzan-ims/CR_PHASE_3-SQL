CREATE TABLE [dbo].[RPT_LEMBAR_PERSETUJUAN_OR_SIMULASI_ADJUSTMENT_DUEDATE] (
    [USER_ID]                NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]         NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]           NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]           NVARCHAR (250)  NOT NULL,
    [ADJUSTMENT_DUEDATE_NO]  NVARCHAR (50)   NULL,
    [AGREEMENT_NO]           NVARCHAR (50)   NULL,
    [KOTA]                   NVARCHAR (50)   NULL,
    [TANGGAL]                DATETIME        NULL,
    [NAMA_CLIENT]            NVARCHAR (250)  NULL,
    [TGL_ADJUSTMENT_DUEDATE] DATETIME        NULL,
    [RENTAL_AMOUNT]          DECIMAL (18, 2) NULL,
    [PENAMBAHAN]             INT             NULL,
    [AKHIR_PERIODE]          DATETIME        NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL
);

