CREATE TABLE [dbo].[DUE_DATE_CHANGE_MAIN] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [CHANGE_STATUS]         NVARCHAR (10)   NOT NULL,
    [CHANGE_DATE]           DATETIME        NOT NULL,
    [CHANGE_EXP_DATE]       DATETIME        NOT NULL,
    [CHANGE_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_CHANGE_DUE_DATE_MAIN_RATE_ADJUESTMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CHANGE_REMARKS]        NVARCHAR (4000) NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NOT NULL,
    [RECEIVED_REQUEST_CODE] NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_NO]   NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_DATE] DATETIME        NULL,
    [IS_AMORTIZATION_VALID] NVARCHAR (1)    CONSTRAINT [DF_DUE_DATE_CHANGE_MAIN_IS_AMORTIZATION_VALID] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [BILLING_TYPE]          NVARCHAR (15)   NULL,
    [BILLING_MODE]          NVARCHAR (15)   NULL,
    [IS_PRORATE]            NVARCHAR (15)   NULL,
    [DATE_FOR_BILLING]      INT             NULL,
    [billing_mode_date]     INT             NULL,
    CONSTRAINT [PK_DUE_DATE_CHANGE_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_CHANGE_DUE_DATE_MAIN_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'CHANGE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa atas perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'CHANGE_EXP_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'CHANGE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'CHANGE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode received request pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor received voucher pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal received voucher pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_DATE';


GO
CREATE NONCLUSTERED INDEX [idx_DUE_DATE_CHANGE_MAIN_20251014]
    ON [dbo].[DUE_DATE_CHANGE_MAIN]([CHANGE_STATUS] ASC)
    INCLUDE([CHANGE_DATE], [AGREEMENT_NO]);

