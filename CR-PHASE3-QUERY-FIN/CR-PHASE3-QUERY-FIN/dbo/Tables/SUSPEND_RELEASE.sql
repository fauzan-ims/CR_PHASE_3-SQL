CREATE TABLE [dbo].[SUSPEND_RELEASE] (
    [CODE]                      NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]               NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]               NVARCHAR (250)  NOT NULL,
    [RELEASE_STATUS]            NVARCHAR (20)   NOT NULL,
    [RELEASE_DATE]              DATETIME        NOT NULL,
    [RELEASE_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_RELEASE_RELEASE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [RELEASE_REMARKS]           NVARCHAR (4000) CONSTRAINT [DF_SUSPEND_RELEASE_RELEASE_REMARKS] DEFAULT ((0)) NOT NULL,
    [RELEASE_BANK_NAME]         NVARCHAR (250)  NOT NULL,
    [RELEASE_BANK_ACCOUNT_NO]   NVARCHAR (50)   NOT NULL,
    [RELEASE_BANK_ACCOUNT_NAME] NVARCHAR (250)  NOT NULL,
    [SUSPEND_CODE]              NVARCHAR (50)   NOT NULL,
    [SUSPEND_CURRENCY_CODE]     NVARCHAR (3)    NOT NULL,
    [SUSPEND_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_RELEASE_REMAINING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUSPEND_RELEASE] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_SUSPEND_RELEASE_SUSPEND_MAIN] FOREIGN KEY ([SUSPEND_CODE]) REFERENCES [dbo].[SUSPEND_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses suspend release tersebut - HOLD, menginformasikan bahwa data suspend release tersebut belum diproses - POST, menginformasikan bahwa data suspend release tersebut telah diposting - PAID, menginformasikan bahwa data suspend release tersebut telah dibayar - CANCEL, menginformasikan bahwa data suspend release tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses release pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai release pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama bank pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor rekening bank pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_BANK_ACCOUNT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama rekening bank pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'RELEASE_BANK_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode suspend pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'SUSPEND_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'SUSPEND_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend pada proses suspend release tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_RELEASE', @level2type = N'COLUMN', @level2name = N'SUSPEND_AMOUNT';

