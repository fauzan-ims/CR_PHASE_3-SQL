CREATE TABLE [dbo].[DEPOSIT_RELEASE] (
    [CODE]                      NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]               NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]               NVARCHAR (250)  NOT NULL,
    [RELEASE_STATUS]            NVARCHAR (20)   NOT NULL,
    [RELEASE_DATE]              DATETIME        NOT NULL,
    [RELEASE_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_DEPOSIT_RELEASE_RELEASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [RELEASE_REMARKS]           NVARCHAR (4000) CONSTRAINT [DF_DEPOSIT_RELEASE_RELEASE_REMARKS] DEFAULT ((0)) NOT NULL,
    [RELEASE_BANK_NAME]         NVARCHAR (250)  NOT NULL,
    [RELEASE_BANK_ACCOUNT_NO]   NVARCHAR (50)   NOT NULL,
    [RELEASE_BANK_ACCOUNT_NAME] NVARCHAR (250)  NOT NULL,
    [AGREEMENT_NO]              NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]             NVARCHAR (3)    NOT NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DEPOSIT_RELEASE] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_DEPOSIT_RELEASE_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses deposit release tersebut - HOLD, menginformasikan bahwa data deposit release tersebut belum diproses - POST, menginformasikan bahwa data deposit release tersebut sudah diposting - CANCEL, menginformasikan bahwa data deposit release tersebut telah dibatalkan - APPROVE, menginformasikan bahwa data deposit release tersebut telah disetujui - REJECT, menginformasikan bahwa data deposit release tersebut telah ditolak - RETURN, menginformasikan bahwa data deposit release tersebut telah dikembalikan ke user maker', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses release pada data deposit release tersebnt', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit yang dilakukan proses release pada data deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama bank pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor rekening bank pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_BANK_ACCOUNT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama rekening bank pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_BANK_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses deposit release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_RELEASE', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';

