CREATE TABLE [dbo].[DEPOSIT_ALLOCATION] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [ALLOCATION_STATUS]        NVARCHAR (10)   NOT NULL,
    [ALLOCATION_TRX_DATE]      DATETIME        NOT NULL,
    [ALLOCATION_VALUE_DATE]    DATETIME        NOT NULL,
    [ALLOCATION_ORIG_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [ALLOCATION_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [ALLOCATION_EXCH_RATE]     DECIMAL (18, 6) NOT NULL,
    [ALLOCATION_BASE_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [ALLOCATIONT_REMARKS]      NVARCHAR (4000) NOT NULL,
    [AGREEMENT_NO]             NVARCHAR (50)   NOT NULL,
    [DEPOSIT_CODE]             NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]             NVARCHAR (15)   NULL,
    [DEPOSIT_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_DEPOSIT_ALLOCATION_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DEPOSIT_GL_LINK_CODE]     NVARCHAR (50)   NOT NULL,
    [IS_RECEIVED_REQUEST]      NVARCHAR (1)    CONSTRAINT [DF_DEPOSIT_ALLOCATION_IS_RECEIVED_REQUEST] DEFAULT ((0)) NOT NULL,
    [REVERSAL_CODE]            NVARCHAR (50)   NULL,
    [REVERSAL_DATE]            DATETIME        NULL,
    [VOUCHER_NO]               NVARCHAR (50)   NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DEPOSIT_ALLOCATION] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_DEPOSIT_ALLOCATION_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi alokasi pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_TRX_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal nilai alokasi tersebut diakui pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai alokasi original pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATIONT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'DEPOSIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data alokasi deposit tersebut berasal dari proses cashier received request?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'IS_RECEIVED_REQUEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode reversal pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'REVERSAL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses reversal pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'REVERSAL_DATE';

