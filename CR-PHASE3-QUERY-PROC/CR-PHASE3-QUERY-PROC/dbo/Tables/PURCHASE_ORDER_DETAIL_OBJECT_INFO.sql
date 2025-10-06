CREATE TABLE [dbo].[PURCHASE_ORDER_DETAIL_OBJECT_INFO] (
    [ID]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [PURCHASE_ORDER_DETAIL_ID]    INT            NOT NULL,
    [GOOD_RECEIPT_NOTE_DETAIL_ID] INT            NULL,
    [PLAT_NO]                     NVARCHAR (50)  NULL,
    [CHASSIS_NO]                  NVARCHAR (50)  NULL,
    [ENGINE_NO]                   NVARCHAR (50)  NULL,
    [SERIAL_NO]                   NVARCHAR (50)  NULL,
    [INVOICE_NO]                  NVARCHAR (50)  NULL,
    [DOMAIN]                      NVARCHAR (50)  NULL,
    [IMEI]                        NVARCHAR (50)  NULL,
    [BPKB_NO]                     NVARCHAR (50)  NULL,
    [COVER_NOTE]                  NVARCHAR (50)  NULL,
    [COVER_NOTE_DATE]             DATETIME       NULL,
    [FILE_PATH]                   NVARCHAR (250) NULL,
    [FILE_NAME]                   NVARCHAR (250) NULL,
    [EXP_DATE]                    DATETIME       NULL,
    [CRE_DATE]                    DATETIME       NOT NULL,
    [CRE_BY]                      NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                    DATETIME       NOT NULL,
    [MOD_BY]                      NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)  NOT NULL,
    [STCK]                        NVARCHAR (50)  NULL,
    [STNK]                        NVARCHAR (50)  NULL,
    [STNK_DATE]                   DATETIME       NULL,
    [STNK_EXP_DATE]               DATETIME       NULL,
    [KEUR]                        NVARCHAR (50)  NULL,
    [KEUR_DATE]                   DATETIME       NULL,
    [KEUR_EXP_DATE]               DATETIME       NULL,
    [STCK_DATE]                   DATETIME       NULL,
    [STCK_EXP_DATE]               DATETIME       NULL,
    [ASSET_CODE]                  NVARCHAR (50)  NULL,
    [STNK_FILE_NO]                NVARCHAR (250) NULL,
    [STNK_FILE_PATH]              NVARCHAR (250) NULL,
    [STCK_FILE_NO]                NVARCHAR (250) NULL,
    [STCK_FILE_PATH]              NVARCHAR (250) NULL,
    [KEUR_FILE_NO]                NVARCHAR (250) NULL,
    [KEUR_FILE_PATH]              NVARCHAR (250) NULL,
    [INVOICE_ID]                  BIGINT         NULL,
    CONSTRAINT [PK_PURCHASE_ORDER_DETAIL_OBJECT_INFO] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PURCHASE_ORDER_DETAIL_OBJECT_INFO_GOOD_RECEIPT_NOTE_DETAIL_ID]
    ON [dbo].[PURCHASE_ORDER_DETAIL_OBJECT_INFO]([GOOD_RECEIPT_NOTE_DETAIL_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PURCHASE_ORDER_DETAIL_OBJECT_INFO_PURCHASE_ORDER_DETAIL_ID_20250615]
    ON [dbo].[PURCHASE_ORDER_DETAIL_OBJECT_INFO]([PURCHASE_ORDER_DETAIL_ID] ASC)
    INCLUDE([PLAT_NO]);

