CREATE TABLE [dbo].[SUSPEND_MAIN] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [SUSPEND_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [SUSPEND_DATE]          DATETIME        NOT NULL,
    [SUSPEND_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_MAIN_SUSPEND_AMOUNT] DEFAULT ((0)) NOT NULL,
    [SUSPEND_REMARKS]       NVARCHAR (4000) NOT NULL,
    [USED_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_MAIN_USED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REMAINING_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_MAIN_REMAINING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REFF_NAME]             NVARCHAR (250)  NULL,
    [REFF_NO]               NVARCHAR (50)   NULL,
    [TRANSACTION_CODE]      NVARCHAR (50)   NULL,
    [TRANSACTION_NAME]      NVARCHAR (250)  NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUSPEND_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'SUSPEND_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'SUSPEND_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'SUSPEND_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend yang digunakan pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'USED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend yang tersisa pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'REMAINING_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'REFF_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada proses suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MAIN', @level2type = N'COLUMN', @level2name = N'REFF_NO';

