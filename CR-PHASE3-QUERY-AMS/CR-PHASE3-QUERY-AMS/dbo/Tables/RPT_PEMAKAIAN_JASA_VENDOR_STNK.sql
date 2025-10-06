CREATE TABLE [dbo].[RPT_PEMAKAIAN_JASA_VENDOR_STNK] (
    [USER_ID]        NVARCHAR (50)  NOT NULL,
    [REPORT_TITLE]   NVARCHAR (50)  NULL,
    [REPORT_IMAGE]   NVARCHAR (50)  NULL,
    [REPORT_COMPANY] NVARCHAR (50)  NULL,
    [BIRO_JASA_CODE] NVARCHAR (50)  NULL,
    [NAMA_BIRO_JASA] NVARCHAR (250) NULL,
    [JANUARI]        INT            NULL,
    [FEBRUARI]       INT            NULL,
    [MARET]          INT            NULL,
    [APRIL]          INT            NULL,
    [MEI]            INT            NULL,
    [JUNI]           INT            NULL,
    [JULI]           INT            NULL,
    [AGUSTUS]        INT            NULL,
    [SEPTEMBER]      INT            NULL,
    [OKTOBER]        INT            NULL,
    [NOVEMBER]       INT            NULL,
    [DESEMBER]       INT            NULL,
    [YEAR]           NVARCHAR (4)   NULL,
    [TYPE]           NVARCHAR (50)  NULL
);

