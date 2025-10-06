CREATE TABLE [dbo].[XXX_ASSET_DEPRECIATION_07112023] (
    [ID]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [ASSET_CODE]                     NVARCHAR (50)   NOT NULL,
    [BARCODE]                        NVARCHAR (50)   NOT NULL,
    [DEPRECIATION_DATE]              DATETIME        NOT NULL,
    [DEPRECIATION_COMMERCIAL_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [NET_BOOK_VALUE_COMMERCIAL]      DECIMAL (18, 2) NOT NULL,
    [DEPRECIATION_FISCAL_AMOUNT]     DECIMAL (18, 2) NOT NULL,
    [NET_BOOK_VALUE_FISCAL]          DECIMAL (18, 2) NOT NULL,
    [PURCHASE_AMOUNT]                DECIMAL (18, 2) NOT NULL,
    [JOURNAL_CODE]                   NVARCHAR (50)   NOT NULL,
    [STATUS]                         NVARCHAR (25)   NOT NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL
);

