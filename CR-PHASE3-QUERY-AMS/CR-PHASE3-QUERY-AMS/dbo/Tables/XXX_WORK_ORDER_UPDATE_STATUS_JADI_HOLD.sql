CREATE TABLE [dbo].[XXX_WORK_ORDER_UPDATE_STATUS_JADI_HOLD] (
    [ASSET_CODE]              NVARCHAR (50)   NULL,
    [ITEM_NAME]               NVARCHAR (250)  NULL,
    [PLAT_NO]                 NVARCHAR (50)   NULL,
    [ENGINE_NO]               NVARCHAR (50)   NULL,
    [CASHISS_NO]              NVARCHAR (50)   NULL,
    [WORK_ORDER_CODE]         NVARCHAR (50)   NULL,
    [SPK_NO]                  NVARCHAR (250)  NULL,
    [PAYMENT_APPROVAL_NUMBER] NVARCHAR (250)  NULL,
    [INVOICE_NO]              NVARCHAR (250)  NULL,
    [CLIENT_NAME]             NVARCHAR (250)  NULL,
    [AGREEMENT_NO]            NVARCHAR (50)   NULL,
    [SERVICE]                 DECIMAL (18, 2) NULL,
    [PPH]                     DECIMAL (18, 2) NULL,
    [SPAREPART]               DECIMAL (18, 2) NULL,
    [PPN]                     DECIMAL (18, 2) NULL,
    [TOTAL]                   DECIMAL (18, 2) NULL,
    [TELAH_DIBAYAR]           NVARCHAR (1)    NULL,
    [TANGGAL_PENGAJUAN_BAYAR] DATETIME        NULL
);

