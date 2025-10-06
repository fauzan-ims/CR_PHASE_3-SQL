CREATE TABLE [dbo].[INSURANCE_PAYMENT_SCHEDULE_RENEWAL] (
    [CODE]                       NVARCHAR (50)   NOT NULL,
    [PAYMENT_RENUAL_STATUS]      NVARCHAR (10)   NOT NULL,
    [POLICY_CODE]                NVARCHAR (50)   NOT NULL,
    [YEAR_PERIOD]                INT             CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_YEAR_PERIOD] DEFAULT ((1)) NOT NULL,
    [POLICY_EFF_DATE]            DATETIME        NOT NULL,
    [POLICY_EXP_DATE]            DATETIME        NOT NULL,
    [SELL_AMOUNT]                DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BUY_AMOUNT]                 DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADJUSTMENT_SELL_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_ADJUSTMENT_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADJUSTMENT_DISCOUNT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_ADJUSTMENT_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADJUSTMENT_BUY_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_ADJUSTMENT_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_AMOUNT]               DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_TOTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPN_AMOUNT]                 DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_PPN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PPH_AMOUNT]                 DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_PPH_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_PAYMENT_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_PAYMENT_SCHEDULE_RENEWAL_TOTAL_PAYMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PAYMENT_REQUEST_CODE]       NVARCHAR (50)   NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_PAYMENT_SCHEDULE_RENEWAL] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses payment renewal tersebut - HOLD, menginformasikan bahwa data data payment renewal tersebut belum diproses - POST, menginformasikan bahwa data data payment renewal tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa data data payment renewal tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'PAYMENT_RENUAL_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'YEAR_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal effektif polis asuransi pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'POLICY_EFF_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa polis asuransi pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'POLICY_EXP_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai premi asuransi costumer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai discount pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai premi beli asuransi ke maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment premi customer pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment discount pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment premi beli asuransi ke maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total premi asuransi setelah dikurangi nilai diskon pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'TOTAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pajak PPN pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pajak PPH pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'PPH_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total pembayaran ke maskapai asuransi setelah ditambah nilai pajak pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'TOTAL_PAYMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode request pembayaran pada proses renewal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_PAYMENT_SCHEDULE_RENEWAL', @level2type = N'COLUMN', @level2name = N'PAYMENT_REQUEST_CODE';

