CREATE TABLE [dbo].[XXX_AP_INVOICE_REGISTRATION_DETAIL_FAKTUR_20240930] (
    [ID]                                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [INVOICE_REGISTRATION_DETAIL_ID]       BIGINT        NULL,
    [PURCHASE_ORDER_DETAIL_OBJECT_INFO_ID] BIGINT        NULL,
    [FAKTUR_NO]                            NVARCHAR (50) NULL,
    [FAKTUR_DATE]                          DATETIME      NULL,
    [CRE_DATE]                             DATETIME      NOT NULL,
    [CRE_BY]                               NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]                       NVARCHAR (15) NOT NULL,
    [MOD_DATE]                             DATETIME      NOT NULL,
    [MOD_BY]                               NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]                       NVARCHAR (15) NOT NULL
);

