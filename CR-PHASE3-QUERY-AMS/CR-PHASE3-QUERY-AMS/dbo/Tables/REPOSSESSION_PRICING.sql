CREATE TABLE [dbo].[REPOSSESSION_PRICING] (
    [CODE]                NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NOT NULL,
    [TRANSACTION_STATUS]  NVARCHAR (10)   NOT NULL,
    [TRANSACTION_DATE]    DATETIME        NOT NULL,
    [TRANSACTION_REMARKS] NVARCHAR (4000) NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_REPOSSESSION_PRICING] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses repossession pricing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_PRICING', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses repossession pricing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_PRICING', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses repossession pricing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_PRICING', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_PRICING', @level2type = N'COLUMN', @level2name = N'TRANSACTION_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi pada proses repossession pricing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_PRICING', @level2type = N'COLUMN', @level2name = N'TRANSACTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses repossession pricing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REPOSSESSION_PRICING', @level2type = N'COLUMN', @level2name = N'TRANSACTION_REMARKS';

