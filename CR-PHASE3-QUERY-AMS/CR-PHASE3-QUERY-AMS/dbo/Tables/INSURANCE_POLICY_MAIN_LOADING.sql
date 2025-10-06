CREATE TABLE [dbo].[INSURANCE_POLICY_MAIN_LOADING] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [POLICY_CODE]         NVARCHAR (50)   NOT NULL,
    [LOADING_CODE]        NVARCHAR (50)   NOT NULL,
    [YEAR_PERIOD]         INT             NOT NULL,
    [INITIAL_BUY_RATE]    DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_POLICY_MAIN_LOADING_INITIAL_BUY_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_RATE]   DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_POLICY_MAIN_LOADING_INITIAL_SELL_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_BUY_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_LOADING_INITIAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_LOADING_INITIAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_BUY_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_LOADING_TOTAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_SELL_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_LOADING_TOTAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_POLICY_MAIN_LOADING] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_INSURANCE_POLICY_MAIN_LOADING_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_INSURANCE_POLICY_MAIN_LOADING_MASTER_COVERAGE_LOADING] FOREIGN KEY ([LOADING_CODE]) REFERENCES [dbo].[MASTER_COVERAGE_LOADING] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada data loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'LOADING_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada data loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'YEAR_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase beli loading asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate jual loading asuransi ke customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai beli loading asuransi pada data loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai jual loading asuransi pada data loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total beli loading asuransi dari maskapai asuransi ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'TOTAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total jual loading asuransi ke customer pada data loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_LOADING', @level2type = N'COLUMN', @level2name = N'TOTAL_SELL_AMOUNT';

