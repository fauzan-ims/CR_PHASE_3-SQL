CREATE TABLE [dbo].[RPT_INVOICE_DELIVERY_DETAIL] (
    [USER_ID]                        NVARCHAR (50)   NULL,
    [CUSTOMER_NAME]                  NVARCHAR (250)  NULL,
    [BRANCH_CODE]                    NVARCHAR (50)   NULL,
    [NO_INVOICE]                     NVARCHAR (50)   NULL,
    [NILAI_DPP]                      DECIMAL (18, 2) NULL,
    [TANGGAL_INVOICE]                DATETIME        NULL,
    [KELENGKAPAN_DOKUMEN_KETERANGAN] NVARCHAR (4000) NULL,
    [PPN]                            DECIMAL (18, 2) NULL,
    [TOTAL_TAGIHAN]                  DECIMAL (18, 2) NULL
);

