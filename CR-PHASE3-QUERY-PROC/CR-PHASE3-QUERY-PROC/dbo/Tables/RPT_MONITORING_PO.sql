CREATE TABLE [dbo].[RPT_MONITORING_PO] (
    [USER_ID]            NVARCHAR (50)   NOT NULL,
    [FILTER_FROM_DATE]   DATETIME        NOT NULL,
    [FILTER_TO_DATE]     DATETIME        NOT NULL,
    [FILTER_BRANCH_CODE] NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]     NVARCHAR (250)  NULL,
    [REPORT_TITLE]       NVARCHAR (250)  NULL,
    [REPORT_IMAGE]       NVARCHAR (250)  NULL,
    [PO_CODE]            NVARCHAR (50)   NULL,
    [PO_DATE]            DATETIME        NULL,
    [ETA_DATE]           DATETIME        NULL,
    [SUPPLIER]           NVARCHAR (250)  NULL,
    [ITEM_CODE]          NVARCHAR (50)   NULL,
    [ITEM_NAME]          NVARCHAR (250)  NULL,
    [CATEGORY_TYPE]      NVARCHAR (50)   NULL,
    [UNIT_PRICE]         DECIMAL (18, 2) NULL,
    [ENGINE_NO]          NVARCHAR (50)   NULL,
    [CHASIS_NO]          NVARCHAR (50)   NULL,
    [BRANCH_NAME]        NVARCHAR (250)  NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [IS_CONDITION]       NVARCHAR (1)    NULL,
    [PROCUREMENT_TYPE]   NVARCHAR (50)   NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_rpt_monitoring_po_user_id_20250615]
    ON [dbo].[RPT_MONITORING_PO]([USER_ID] ASC);

