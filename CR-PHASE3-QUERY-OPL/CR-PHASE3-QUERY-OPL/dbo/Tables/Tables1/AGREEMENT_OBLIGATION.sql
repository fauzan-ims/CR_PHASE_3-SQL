CREATE TABLE [dbo].[AGREEMENT_OBLIGATION] (
    [CODE]               NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]       NVARCHAR (50)   NOT NULL,
    [ASSET_NO]           NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]         NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]     INT             NOT NULL,
    [OBLIGATION_DAY]     INT             NOT NULL,
    [OBLIGATION_DATE]    DATETIME        NOT NULL,
    [OBLIGATION_TYPE]    NVARCHAR (10)   NOT NULL,
    [OBLIGATION_NAME]    NVARCHAR (250)  NOT NULL,
    [OBLIGATION_REFF_NO] NVARCHAR (50)   NOT NULL,
    [OBLIGATION_AMOUNT]  DECIMAL (18, 2) NOT NULL,
    [REMARKS]            NVARCHAR (4000) NOT NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_OBLIGATION] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_AGREEMENT_OBLIGATION_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_OBLIGATION_20230814]
    ON [dbo].[AGREEMENT_OBLIGATION]([OBLIGATION_TYPE] ASC)
    INCLUDE([AGREEMENT_NO], [ASSET_NO], [INVOICE_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_OBLIGATION_20231019]
    ON [dbo].[AGREEMENT_OBLIGATION]([AGREEMENT_NO] ASC)
    INCLUDE([OBLIGATION_AMOUNT]);


GO
CREATE NONCLUSTERED INDEX [IDX_20250827_4]
    ON [dbo].[AGREEMENT_OBLIGATION]([AGREEMENT_NO] ASC, [OBLIGATION_TYPE] ASC)
    INCLUDE([OBLIGATION_AMOUNT]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'OBLIGATION_DAY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal obligasi pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'OBLIGATION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe obligasi pada data obligasi kontrak pembiayaan tersebut (Cth : OVDP = Overdue Penalty)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'OBLIGATION_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama obligasi pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'OBLIGATION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi obligasi pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'OBLIGATION_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai obligasi pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'OBLIGATION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data obligasi kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_OBLIGATION', @level2type = N'COLUMN', @level2name = N'REMARKS';

