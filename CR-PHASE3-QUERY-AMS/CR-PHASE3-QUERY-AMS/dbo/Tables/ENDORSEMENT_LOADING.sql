CREATE TABLE [dbo].[ENDORSEMENT_LOADING] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [ENDORSEMENT_CODE]    NVARCHAR (50)   NOT NULL,
    [OLD_OR_NEW]          NVARCHAR (3)    NOT NULL,
    [LOADING_CODE]        NVARCHAR (50)   NOT NULL,
    [YEAR_PERIOD]         INT             NOT NULL,
    [INITIAL_BUY_RATE]    DECIMAL (9, 6)  CONSTRAINT [DF_ENDORSEMENT_LOADING_INITIAL_BUY_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_RATE]   DECIMAL (9, 6)  CONSTRAINT [DF_ENDORSEMENT_LOADING_INITIAL_SELL_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_BUY_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_LOADING_INITIAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_SELL_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_LOADING_INITIAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_BUY_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_LOADING_TOTAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_SELL_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_LOADING_TOTAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REMAIN_BUY]          DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_LOADING_REMAIN_BUY] DEFAULT ((0)) NOT NULL,
    [REMAIN_SELL]         DECIMAL (18, 2) CONSTRAINT [DF_ENDORSEMENT_LOADING_REMAIN_SELL] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ENDORSEMENT_LOADING] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ENDORSEMENT_LOADING_ENDORSEMENT_MAIN] FOREIGN KEY ([ENDORSEMENT_CODE]) REFERENCES [dbo].[ENDORSEMENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode endorsement pada proses loading endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Menginformasikan apakah data tersebut merupakan data sebelum atau sesudah dilakukan proses endorsement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'OLD_OR_NEW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode loading pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'LOADING_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada proses loading endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'YEAR_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate beli initial asuransi dari maskapai', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate jual initial asuransi ke customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai beli initial asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai jual initial asuransi ke customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'INITIAL_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total beli asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'TOTAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total jual asuransi ke customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'TOTAL_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa premi beli asuransi pada proses loading endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'REMAIN_BUY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa premi jual asuransi pada proses loading endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_LOADING', @level2type = N'COLUMN', @level2name = N'REMAIN_SELL';

