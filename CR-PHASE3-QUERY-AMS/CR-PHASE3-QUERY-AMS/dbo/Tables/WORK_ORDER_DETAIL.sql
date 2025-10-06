CREATE TABLE [dbo].[WORK_ORDER_DETAIL] (
    [ID]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [WORK_ORDER_CODE]               NVARCHAR (50)   CONSTRAINT [DF_Table_1_MAINTENANCE_CODE] DEFAULT ('') NOT NULL,
    [ASSET_MAINTENANCE_SCHEDULE_ID] BIGINT          NULL,
    [SERVICE_CODE]                  NVARCHAR (50)   CONSTRAINT [DF_WORK_ORDER_DETAIL_SERVICE_CODE] DEFAULT ('') NOT NULL,
    [SERVICE_NAME]                  NVARCHAR (250)  NULL,
    [SERVICE_TYPE]                  NVARCHAR (50)   NULL,
    [SERVICE_FEE]                   DECIMAL (18, 2) NULL,
    [QUANTITY]                      INT             NULL,
    [PPH_AMOUNT]                    DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]                    DECIMAL (18, 2) NULL,
    [TOTAL_AMOUNT]                  DECIMAL (18, 2) NULL,
    [PAYMENT_AMOUNT]                DECIMAL (18, 2) NULL,
    [TAX_CODE]                      NVARCHAR (50)   NULL,
    [TAX_NAME]                      NVARCHAR (250)  NULL,
    [PPN_PCT]                       DECIMAL (9, 6)  NULL,
    [PPH_PCT]                       DECIMAL (9, 6)  NULL,
    [PART_NUMBER]                   NVARCHAR (50)   NULL,
    [AGREEMENT_NO]                  NVARCHAR (50)   NULL,
    [ASSET_CODE]                    NVARCHAR (50)   NULL,
    [CRE_DATE]                      DATETIME        NOT NULL,
    [CRE_BY]                        NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                NVARCHAR (50)   NOT NULL,
    [MOD_DATE]                      DATETIME        NOT NULL,
    [MOD_BY]                        NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                NVARCHAR (50)   NOT NULL,
    CONSTRAINT [PK_WORK_ORDER_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_WORK_ORDER_DETAIL_20230409]
    ON [dbo].[WORK_ORDER_DETAIL]([WORK_ORDER_CODE] ASC)
    INCLUDE([SERVICE_NAME], [SERVICE_TYPE], [PAYMENT_AMOUNT], [PART_NUMBER]);


GO
CREATE NONCLUSTERED INDEX [IDX_WORK_ORDER_DETAIL_20230905]
    ON [dbo].[WORK_ORDER_DETAIL]([ASSET_CODE] ASC)
    INCLUDE([PAYMENT_AMOUNT]);

