CREATE TABLE [dbo].[CASHIER_RECEIVED_REQUEST] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [REQUEST_STATUS]           NVARCHAR (10)   CONSTRAINT [DF_CASHIER_RECEIVED_REQUEST_STATUS] DEFAULT (N'') NOT NULL,
    [REQUEST_CURRENCY_CODE]    NVARCHAR (5)    NOT NULL,
    [REQUEST_DATE]             DATETIME        CONSTRAINT [DF_CASHIER_RECEIVED_REQUEST_RECEIVED_REQUEST_STATUS1] DEFAULT (N'') NOT NULL,
    [REQUEST_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_RECEIVED_REQUEST_RECEIVED_REQUEST_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REQUEST_REMARKS]          NVARCHAR (1000) NOT NULL,
    [AGREEMENT_NO]             NVARCHAR (50)   NULL,
    [PDC_CODE]                 NVARCHAR (50)   NULL,
    [PDC_NO]                   NVARCHAR (50)   NULL,
    [DOC_REF_CODE]             NVARCHAR (50)   NOT NULL,
    [DOC_REF_NAME]             NVARCHAR (250)  NOT NULL,
    [DOC_REF_FLAG]             NVARCHAR (10)   CONSTRAINT [DF_CASHIER_RECEIVED_REQUEST_DOC_REF_FLAG] DEFAULT ('') NOT NULL,
    [COLLECTOR_CODE]           NVARCHAR (50)   NULL,
    [COLLECTOR_NAME]           NVARCHAR (250)  NULL,
    [PDC_ALLOCATION_TYPE]      NVARCHAR (15)   NULL,
    [BRANCH_BANK_CODE]         NVARCHAR (50)   NULL,
    [BRANCH_BANK_NAME]         NVARCHAR (250)  NULL,
    [BRANCH_BANK_GL_LINK_CODE] NVARCHAR (50)   NULL,
    [PROCESS_DATE]             DATETIME        NULL,
    [PROCESS_REFF_CODE]        NVARCHAR (250)  NULL,
    [PROCESS_REFF_NAME]        NVARCHAR (50)   NULL,
    [VOUCHER_NO]               NVARCHAR (50)   NULL,
    [INVOICE_NO]               NVARCHAR (50)   NULL,
    [INVOICE_EXTERNAL_NO]      NVARCHAR (50)   NULL,
    [INVOICE_DATE]             DATETIME        NULL,
    [INVOICE_DUE_DATE]         DATETIME        NULL,
    [INVOICE_BILLING_AMOUNT]   DECIMAL (18, 2) NULL,
    [INVOICE_PPN_AMOUNT]       DECIMAL (18, 2) NULL,
    [INVOICE_PPH_AMOUNT]       DECIMAL (18, 2) NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NULL,
    [CLIENT_NO]                NVARCHAR (50)   NULL,
    [CLIENT_NAME]              NVARCHAR (250)  NULL,
    CONSTRAINT [PK_CASHIER_RECEIVED_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_CASHIER_RECEIVED_REQUEST_20240201]
    ON [dbo].[CASHIER_RECEIVED_REQUEST]([INVOICE_NO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PROCESS_REFF_CODE_20250718]
    ON [dbo].[CASHIER_RECEIVED_REQUEST]([PROCESS_REFF_CODE] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses request pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang di request pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode PDC pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PDC_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor PDC pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PDC_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode referensi dokumen pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'DOC_REF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi dokumen pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'DOC_REF_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi dokumen pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_REFF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi dokumen pada data request penerimaan kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_REFF_NAME';

