CREATE TABLE [dbo].[ENDORSEMENT_PERIOD] (
    [ID]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [ENDORSEMENT_CODE]              NVARCHAR (50)   NOT NULL,
    [OLD_OR_NEW]                    NVARCHAR (3)    NOT NULL,
    [SUM_INSURED]                   DECIMAL (18, 2) NOT NULL,
    [RATE_DEPRECIATION]             DECIMAL (9, 6)  CONSTRAINT [DF_ENDORSEMENT_PERIOD_RATE_DEPRECIATION] DEFAULT ((0)) NOT NULL,
    [COVERAGE_CODE]                 NVARCHAR (50)   NOT NULL,
    [YEAR_PERIOD]                   INT             NOT NULL,
    [INITIAL_BUY_RATE]              DECIMAL (9, 6)  CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_BUY_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_RATE]             DECIMAL (9, 6)  CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_SELL_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_BUY_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BUY_AMOUNT]                    DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [SELL_AMOUNT]                   DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_DISCOUNT_PCT]          DECIMAL (9, 6)  CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_DISCOUNT_PCT] DEFAULT ((0)) NOT NULL,
    [INITIAL_DISCOUNT_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_BUY_ADMIN_FEE_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_BUY_ADMIN_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_ADMIN_FEE_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_SELL_ADMIN_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_STAMP_FEE_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_INITIAL_STAMP_FEE_AMOUNT_1] DEFAULT ((0)) NOT NULL,
    [TOTAL_BUY_AMOUNT]              DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_TOTAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_SELL_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_TOTAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REMAIN_BUY]                    DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_REMAIN_BUY] DEFAULT ((0)) NOT NULL,
    [REMAIN_SELL]                   DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_PERIOD_REMAIN_SELL] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                      DATETIME        NOT NULL,
    [CRE_BY]                        NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                      DATETIME        NOT NULL,
    [MOD_BY]                        NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ENDORSEMENT_PERIOD] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ENDORSEMENT_PERIOD_ENDORSEMENT_MAIN] FOREIGN KEY ([ENDORSEMENT_CODE]) REFERENCES [dbo].[ENDORSEMENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode endorsement pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'menginformasikan apakah data tersebut merupakan data sebelum atau sesudah dilakukan proses endorsement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'OLD_OR_NEW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh maskapai asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'SUM_INSURED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate depresiasi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'RATE_DEPRECIATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'YEAR_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate beli initial asurnasi dari maskapai asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Presentase rate jual asuransi ke customer pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai beli asuransi dari maskapai pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai jual asuransi ke customer pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai premi beli asuransi dari maskapai asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai jual premi asuransi ke customer pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase diskon initial premi asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_DISCOUNT_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai diskon premi asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya admin beli asuransi dari maskapai asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_ADMIN_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya admin jual asuransi ke customer pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_ADMIN_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biaya materai pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'INITIAL_STAMP_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total beli asuransi dari maskapai pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'TOTAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total jual asuransi ke customer pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'TOTAL_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa premi asuransi dari maskapai asuransi pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'REMAIN_BUY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa premi jual asuransi ke customer pada periode endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_PERIOD', @level2type = N'COLUMN', @level2name = N'REMAIN_SELL';

