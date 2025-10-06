CREATE TABLE [dbo].[DEPOSIT_MOVE] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [MOVE_STATUS]            NVARCHAR (10)   NOT NULL,
    [MOVE_DATE]              DATETIME        NOT NULL,
    [MOVE_REMARKS]           NVARCHAR (4000) NOT NULL,
    [FROM_DEPOSIT_CODE]      NVARCHAR (50)   NOT NULL,
    [FROM_AGREEMENT_NO]      NVARCHAR (50)   NOT NULL,
    [FROM_DEPOSIT_TYPE_CODE] NVARCHAR (15)   NOT NULL,
    [FROM_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_MOVE_ADVANCE_FROM_AMOUNT] DEFAULT (N'0') NOT NULL,
    [TO_AGREEMENT_NO]        NVARCHAR (50)   NOT NULL,
    [TO_DEPOSIT_TYPE_CODE]   NVARCHAR (15)   NOT NULL,
    [TO_AMOUNT]              DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_MOVE_ADVANCE_TO_AMOUNT] DEFAULT (N'0') NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [TOTAL_TO_AMOUNT]        DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_DEPOSIT_MOVE] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_DEPOSIT_MOVE_AGREEMENT_MAIN] FOREIGN KEY ([FROM_AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]),
    CONSTRAINT [FK_DEPOSIT_MOVE_AGREEMENT_MAIN1] FOREIGN KEY ([TO_AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses deposit move tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses deposit move tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses deposit move tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses deposit move tersebut - HOLD, menginformasikan bahwa data deposit move tersebut belum diproses - POST, menginformasikan bahwa data deposit move tersebut telah diposting - CANCEL, menginformasikan bahwa data deposit move tersebut telah dibatalkan - APPROVE, menginformasikan bahwa data deposit move tersebut telah disetujui - REJECT, menginformasikan bahwa data deposit move tersebut telah ditolak - RETURN, menginformasikan bahwa data deposit move tersebut dikembalikan ke user maker', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'MOVE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses move deposit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'MOVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses deposit move tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'MOVE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit sebelum sebelum dilakukan proses deposit move tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'FROM_DEPOSIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asal kontrak pembiayaan sebelum dilakukan atas proses deposit move yang dilakukan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'FROM_AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tipe deposit sebelum dilakukan proses deposit move', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'FROM_DEPOSIT_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit sebelum dilakukan proses deposit move', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'FROM_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor tujuan kontrak pembiayaan setelah dilakukan atas proses deposit move yang dilakukan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'TO_AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tipe deposit setelah dilakukan proses deposit move', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'TO_DEPOSIT_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit setelah dilakukan proses deposit move', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEPOSIT_MOVE', @level2type = N'COLUMN', @level2name = N'TO_AMOUNT';

