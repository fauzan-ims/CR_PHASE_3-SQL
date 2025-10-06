CREATE TABLE [dbo].[ET_MAIN] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NOT NULL,
    [ET_STATUS]             NVARCHAR (10)   NOT NULL,
    [ET_DATE]               DATETIME        NOT NULL,
    [ET_EXP_DATE]           DATETIME        NOT NULL,
    [ET_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_ET_MAIN_ET_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ET_REMARKS]            NVARCHAR (4000) NOT NULL,
    [RECEIVED_REQUEST_CODE] NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_NO]   NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_DATE] DATETIME        NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [FILE_NAME]             NVARCHAR (250)  NULL,
    [FILE_PATH]             NVARCHAR (250)  NULL,
    [REASON]                NVARCHAR (4000) NULL,
    [REFUND_AMOUNT]         DECIMAL (18, 2) NULL,
    [CREDIT_NOTE_AMOUNT]    DECIMAL (18, 2) NULL,
    [BANK_CODE]             NVARCHAR (50)   NULL,
    [BANK_NAME]             NVARCHAR (250)  NULL,
    [BANK_ACCOUNT_NO]       NVARCHAR (50)   NULL,
    [BANK_ACCOUNT_NAME]     NVARCHAR (250)  NULL,
    CONSTRAINT [PK_ET_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ET_MAIN_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_20250203_ET_MAIN]
    ON [dbo].[ET_MAIN]([AGREEMENT_NO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses pelunasan dipercepat pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'ET_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'ET_EXP_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pelunasan dipercepat pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'ET_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'ET_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode received request pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor received voucher pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tanggal received voucher pada data ET main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_DATE';

