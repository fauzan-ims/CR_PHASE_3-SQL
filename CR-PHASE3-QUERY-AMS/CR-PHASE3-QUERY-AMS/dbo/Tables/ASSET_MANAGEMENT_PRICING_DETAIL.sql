CREATE TABLE [dbo].[ASSET_MANAGEMENT_PRICING_DETAIL] (
    [ID]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [PRICING_CODE]              NVARCHAR (50)   NOT NULL,
    [ASSET_CODE]                NVARCHAR (50)   NOT NULL,
    [PRICELIST_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_ASSET_MANAGEMENT_PRICING_DETAIL_PRICELIST_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PRICING_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_ASSET_MANAGEMENT_PRICING_DETAIL_PRICING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REQUEST_AMOUNT]            DECIMAL (18, 2) NOT NULL,
    [APPROVE_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_ASSET_MANAGEMENT_PRICING_DETAIL_APPROVE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ESTIMATE_GAIN_LOSS_PCT]    DECIMAL (9, 6)  NOT NULL,
    [ESTIMATE_GAIN_LOSS_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [NET_BOOK_VALUE_FISCAL]     DECIMAL (18, 2) NOT NULL,
    [NET_BOOK_VALUE_COMM]       DECIMAL (18, 2) NOT NULL,
    [COLLATERAL_LOCATION]       NVARCHAR (4000) NULL,
    [COLLATERAL_DESCRIPTION]    NVARCHAR (250)  NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ASSET_MANAGEMENT_PRICING_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pricing pada data repossession pricing detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'PRICING_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode repossession pada data repossession pricing detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'ASSET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pricing yang di request pada data repossession pricing detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'REQUEST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pricing yang disetujui pada data repossession pricing detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'APPROVE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Perkiraan persentase untung atau rugi pada data repossession pricing detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'ESTIMATE_GAIN_LOSS_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai perkiraan estimasi untung atau rugi pada data repossession pricing detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_MANAGEMENT_PRICING_DETAIL', @level2type = N'COLUMN', @level2name = N'ESTIMATE_GAIN_LOSS_AMOUNT';

