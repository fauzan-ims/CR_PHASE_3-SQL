CREATE TABLE [dbo].[BANK_MUTATION] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]      NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]      NVARCHAR (250)  NOT NULL,
    [BRANCH_BANK_CODE] NVARCHAR (50)   NOT NULL,
    [BRANCH_BANK_NAME] NVARCHAR (250)  NOT NULL,
    [GL_LINK_CODE]     NVARCHAR (50)   NOT NULL,
    [BALANCE_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_Table_1_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_BANK_MUTATION] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION', @level2type = N'COLUMN', @level2name = N'GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit pada data deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BANK_MUTATION', @level2type = N'COLUMN', @level2name = N'BALANCE_AMOUNT';

