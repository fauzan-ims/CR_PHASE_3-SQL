CREATE TABLE [dbo].[GOOD_RECEIPT_NOTE_DETAIL_OBJECT_INFO] (
    [ID]                          BIGINT        IDENTITY (1, 1) NOT NULL,
    [GOOD_RECEIPT_NOTE_DETAIL_ID] INT           NOT NULL,
    [PLAT_NO]                     NVARCHAR (50) NULL,
    [CHASSIS_NO]                  NVARCHAR (50) NULL,
    [ENGINE_NO]                   NVARCHAR (50) NULL,
    [SERIAL_NO]                   NVARCHAR (50) NULL,
    [INVOICE_NO]                  NVARCHAR (50) NULL,
    [DOMAIN]                      NVARCHAR (50) NULL,
    [IMEI]                        NVARCHAR (50) NULL,
    [CRE_DATE]                    DATETIME      NOT NULL,
    [CRE_BY]                      NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15) NOT NULL,
    [MOD_DATE]                    DATETIME      NOT NULL,
    [MOD_BY]                      NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_GOOD_RECEIPT_NOTE_DETAIL_OBJECT_INFO] PRIMARY KEY CLUSTERED ([ID] ASC)
);

