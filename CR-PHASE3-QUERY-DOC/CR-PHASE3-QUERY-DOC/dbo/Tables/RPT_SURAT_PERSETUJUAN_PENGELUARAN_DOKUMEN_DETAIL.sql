CREATE TABLE [dbo].[RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL] (
    [USER_ID]              NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]       NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]         NVARCHAR (250)  NULL,
    [REPORT_IMAGE]         NVARCHAR (50)   NULL,
    [AGREEMENT_NO]         NVARCHAR (50)   NULL,
    [AGREEMENT_DATE]       NVARCHAR (50)   NULL,
    [VALUE_DATE]           NVARCHAR (50)   NULL,
    [LEESEE_CONSUMER_NAME] NVARCHAR (250)  NULL,
    [LEESEE_CONSUMER_NO]   NVARCHAR (250)  NULL,
    [ID]                   BIGINT          NULL,
    [ASSET_CODE]           NVARCHAR (50)   NULL,
    [OBJECT_NAME]          NVARCHAR (250)  NULL,
    [DOCUMENT_TYPE]        NVARCHAR (250)  NULL,
    [DOCUMENT_NO]          NVARCHAR (50)   NULL,
    [REMARK]               NVARCHAR (4000) NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

