CREATE TABLE [dbo].[RPT_CONTROL_CARD_MAINTENANCE] (
    [USER_ID]                 NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]          NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]            NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]            NVARCHAR (250)  NOT NULL,
    [AGREEMENT_NO]            NVARCHAR (50)   NULL,
    [CUSTOMER_NAME]           NVARCHAR (250)  NULL,
    [FIXED_ASSET_CODE]        NVARCHAR (50)   NULL,
    [FIXED_ASSET_DESCRIPTION] NVARCHAR (100)  NULL,
    [PLAT_NO]                 NVARCHAR (50)   NULL,
    [MERK_OR_TYPE]            NVARCHAR (250)  NULL,
    [CHASSIS_NO]              NVARCHAR (50)   NULL,
    [ENGINE_NO]               NVARCHAR (50)   NULL,
    [CONTRACT_PERIOD]         NVARCHAR (50)   NULL,
    [BUDGET_MAINTENANCE]      DECIMAL (18, 2) NULL,
    [SERVICE_DATE]            DATETIME        NULL,
    [KM]                      INT             NULL,
    [PEKERJAAN]               NVARCHAR (250)  NULL,
    [JASA]                    INT             NULL,
    [JENIS_ITEM]              NVARCHAR (250)  NULL,
    [PART_NUMBER]             NVARCHAR (50)   NULL,
    [HARGA]                   DECIMAL (18, 2) NULL,
    [JENIS_ITEM_SUB]          NVARCHAR (250)  NULL,
    [HARGA_SUB]               DECIMAL (18, 2) NULL,
    [PEKERJAAN_SPECIAL_ORDER] NVARCHAR (250)  NULL,
    [HARGA_SPECIAL_ORDER]     DECIMAL (18, 2) NULL,
    [TOTAL_BIAYA]             DECIMAL (18, 2) NULL,
    [WORKSHOP]                NVARCHAR (250)  NULL,
    [REMAINING_BUDGET]        DECIMAL (18, 2) NULL,
    [PPN]                     DECIMAL (18, 2) NULL,
    [PPH]                     DECIMAL (18, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_RPT_CONTROL_CARD_MAINTENANCE_20230904]
    ON [dbo].[RPT_CONTROL_CARD_MAINTENANCE]([USER_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_RPT_CONTROL_CARD_MAINTENANCE_20230409_2]
    ON [dbo].[RPT_CONTROL_CARD_MAINTENANCE]([USER_ID] ASC, [AGREEMENT_NO] ASC);

