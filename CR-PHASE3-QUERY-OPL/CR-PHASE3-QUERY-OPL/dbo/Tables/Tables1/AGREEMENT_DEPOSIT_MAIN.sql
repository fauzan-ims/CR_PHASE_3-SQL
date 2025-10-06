CREATE TABLE [dbo].[AGREEMENT_DEPOSIT_MAIN] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]          NVARCHAR (15)   NOT NULL,
    [DEPOSIT_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [DEPOSIT_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_DEPOSIT_MAIN_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_DEPOSIT_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data deposit kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data deposit kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data deposit kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data deposit kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe deposit pada data deposit kontrak pembiayaan tersebut - INSTALLMENT, menginformasikan bahwa biaya deposit tersebut merupakan deposit angsuran - INSURANCE, menginformasikan bahwa biaya deposit tersebut merupakan deposit asuransi - OTHER, menginformasikan bahwa biaya deposit tersebut merupakan deposit lain lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'DEPOSIT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang pada data deposit kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'DEPOSIT_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit pada data deposit kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_DEPOSIT_MAIN', @level2type = N'COLUMN', @level2name = N'DEPOSIT_AMOUNT';

